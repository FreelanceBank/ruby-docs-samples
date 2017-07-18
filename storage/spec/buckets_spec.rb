# Copyright 2016 Google, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require_relative "../buckets"
require "rspec"
require "google/cloud/storage"

describe "Google Cloud Storage buckets sample" do

  before :all do
    @bucket_name = ENV["GOOGLE_CLOUD_STORAGE_BUCKET"]
    @storage     = Google::Cloud::Storage.new
    @project_id  = @storage.project
  end

  before do
    delete_bucket!
    @storage.create_bucket @bucket_name
  end

  after :all do
    # Other tests assume that this bucket exists,
    # so create it before exiting this spec suite
    @storage.create_bucket @bucket_name unless @storage.bucket(@bucket_name)
  end

  def delete_bucket!
    bucket = @storage.bucket @bucket_name

    if bucket
      bucket.files.each &:delete until bucket.files.empty?
      bucket.delete
    end
  end

  example "list buckets" do
    expect {
      list_buckets project_id: @project_id
    }.to output(
      /#{@bucket_name}/
    ).to_stdout
  end

  example "create bucket" do
    delete_bucket!

    expect(@storage.bucket @bucket_name).to be nil

    expect {
      create_bucket project_id:  @project_id,
                    bucket_name: @bucket_name
    }.to output(
      "Created bucket: #{@bucket_name}\n"
    ).to_stdout

    expect(@storage.bucket @bucket_name).not_to be nil
  end

  example "create bucket with NEARLINE and multi-region(US) location" do
    delete_bucket!

    expect(@storage.bucket @bucket_name).to be nil

    location      = "US"
    storage_class = "NEARLINE"

    expect {
      create_bucket_with_class_location project_id:  @project_id,
                                        bucket_name: @bucket_name,
                                        location: location,
                                        storage_class: storage_class
    }.to output(
      "Created bucket #{@bucket_name} in #{location} with #{storage_class} class\n"
    ).to_stdout

    new_bucket = @storage.bucket @bucket_name
    expect(new_bucket).not_to be nil
    expect(new_bucket.location).to eq(location)
    expect(new_bucket.storage_class).to eq(storage_class)
  end

  example "delete bucket" do
    expect(@storage.bucket @bucket_name).not_to be nil

    expect {
      delete_bucket project_id: @project_id, bucket_name: @bucket_name
    }.to output(
      "Deleted bucket: #{@bucket_name}\n"
    ).to_stdout

    expect(@storage.bucket @bucket_name).to be nil
  end

end
