# # encoding: utf-8

# Inspec test for recipe solr::default

# The Inspec reference, with examples and extensive documentation, can be
# found at http://inspec.io/docs/reference/resources/

unless os.windows?
  # This is an example test, replace with your own test.
  describe user('root') do
    it { should exist }
  end
end

# This is an example test, replace it with your own test.

describe service 'solr' do
  it { should be_enabled }
#  it { should be_running }
end

describe port 8983 do
  it { should be_listening }
end
