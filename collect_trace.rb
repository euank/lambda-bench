#!/usr/bin/env ruby

require 'aws-sdk'
require 'json'
require 'csv'

Aws.config.update({
  region: 'us-west-2',
})

prefix=ARGV.shift
lambda_size=ARGV.shift

xray = Aws::XRay::Client.new({region: 'us-west-2'})

fns = {}

ARGV.each do |fn|
  summaries = []
  until summaries.size == 2 do
    # Note: unlike most AWS services, xray really needs you to paginate.
    # They go so far as to return entirely empty responses except for having a next_token set.
    # Nice API
    summaries = xray.get_trace_summaries({
      start_time: (Time.now - 60 * 60 * 3),
      end_time: Time.now,
      filter_expression: %{service("#{prefix}#{fn}")},
    }).map{|page| page.trace_summaries}.flatten
    sleep(10) if summaries.size != 2
  end
  fns[fn] = summaries
end

# Now get the segment breakdown, summaries just gives us duration

details = []
fns.each do |fn, summary|
  # Exceeding maximum query size: 5 (Aws::XRay::Errors::InvalidRequestException) if I request more than 5 at
  # once in a so-called "batch" api. What the ?
  details += xray.batch_get_traces({
    trace_ids: summary.map{|el| el.id},
  }).traces
end

def get_data(details)
  fn_seg = details.segments.map{|seg| JSON.parse(seg.document)}.select{|doc| doc["origin"] == "AWS::Lambda::Function"}.first
  lambda_seg = details.segments.map{|seg| JSON.parse(seg.document)}.select{|doc| doc["origin"] == "AWS::Lambda"}.first
  {
    duration: details.duration,
    time: Time.at(fn_seg["start_time"]),
    fn_duration: fn_seg["end_time"] - fn_seg["start_time"],
    lambda_duration: lambda_seg["end_time"] - lambda_seg["start_time"],
  }
end

CSV do |out|
  out << %w{Function Lambda_Size Time Warmth Duration Lambda_Duration Function_Duration}

  fns.each do |fn, summaries|
    data = summaries.map do |s| 
      deets = details.select{|d| d.id == s.id}.first
      raise "No details for #{id}" if deets.nil?
      get_data(deets)
    end

    if data[0][:time] < data[1][:time]
      cold, warm = data[0], data[1]
    else
      warm, cold = data[0], data[1]
    end

    out << [fn, lambda_size, cold[:time], "cold", cold[:duration], cold[:lambda_duration], cold[:fn_duration]]
    out << [fn, lambda_size, warm[:time], "warm", warm[:duration], warm[:lambda_duration], warm[:fn_duration]]
  end
end
