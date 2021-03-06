#!/usr/bin/env ruby
# Encoding: utf-8
#
# Author:: api.jimper@gmail.com (Jonathon Imperiosi)
#
# Copyright:: Copyright 2014, Google Inc. All Rights Reserved.
#
# License:: Licensed under the Apache License, Version 2.0 (the "License");
#           you may not use this file except in compliance with the License.
#           You may obtain a copy of the License at
#
#           http://www.apache.org/licenses/LICENSE-2.0
#
#           Unless required by applicable law or agreed to in writing, software
#           distributed under the License is distributed on an "AS IS" BASIS,
#           WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#           implied.
#           See the License for the specific language governing permissions and
#           limitations under the License.
#
# This example displays advertiser name, ID and spotlight configuration ID for
# the given search criteria. Results are limited to first 10 records.
#
# Tags: advertiser.getAdvertisers

require_relative 'dfa_utils'

def get_advertisers(search_string, auth_token)
  # Get the advertiser service.
  advertiser_service = Savon.client(
    :wsdl => DfaUtils.generate_wsdl_url('advertiser'),
    # Set the WSSE authentication header.
    :wsse_auth => [DfaUtils.get_dfa_username(), auth_token])

  # Create advertiser search criteria structure.
  advertiser_search_criteria = {
    :page_number => 0,
    :page_size => 10,
    :search_string => search_string
  }

  # Fetch the advertisers.
  response = advertiser_service.call(
    :get_advertisers,
    :message => {:advertiser_search_criteria => advertiser_search_criteria},
    :soap_header => DfaUtils.generate_request_header())

  response = response.to_hash[:multi_ref]

  # Display advertiser names, IDs and spotlight configuration IDs.
  if response[0] && response[0][:records]
    record_set = response[0][:records][:records]
    # Ensure records are wrapped in an array, even if there is only one
    # record.
    record_set = [record_set] unless record_set.is_a?(Array)

    record_set.each do |record|
      # Extract the href from the record. The href will specify which element
      # of the response multi_ref array contains the object this record
      # refers to.
      record_href = record[:@href][/#id(.*)/,1].to_i
      advertiser = response[record_href]
      puts ('Advertiser with name "%s", ID %d, and floodlight ' +
          'configuration ID %d was found.') % [advertiser[:name],
          advertiser[:id], advertiser[:spot_id]]
    end
  else
    puts 'No advertisers found for your criteria.'
  end
end

if __FILE__ == $0
  # Provide criteria to search upon.
  search_string = 'INSERT_SEARCH_STRING_CRITERIA_HERE'

  # Generate a DFA authentication token.
  auth_token = DfaUtils.authenticate()

  get_advertisers(search_string, auth_token)
end
