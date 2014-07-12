require File.expand_path('../../spec_helper', __FILE__)
include RightApi::Helper

describe RightApi::Helper, :unit=>true do

  API_MEDIA_TYPES = %w{audit_entry ip_address process server}

  context "#is_singular?" do
    API_MEDIA_TYPES.each do |media_type|
      it "should identify media type #{media_type} as singular" do
        is_singular?(media_type).should == true
      end
    end
  end

  context "#fix_array_of_hashes" do
    it "fixes all the keys that have the value as array of hashes" do
      res = fix_array_of_hashes(
          'a' => '1',
          'b' => [1, 2, 3],
          'c' => {1 => 2, 3 => 4},
          'd' => [
              {5 => 6, 7 => 8},
              {9 => 10, 11 => 12}
          ]
      )

      res.should == {
          'a' => '1',
          'b' => [1, 2, 3],
          'c' => {1 => 2, 3 => 4},
          'd[]' => [
              {5 => 6, 7 => 8},
              {9 => 10, 11 => 12}
          ]
      }

    end

    it "fixes key that have a top-level array of hashes as value" do
      res = fix_array_of_hashes(
          'a' => [
              {1 => 2},
              {3 => 4}
          ]
      )

      res.should == {
          'a[]' => [
              {1 => 2},
              {3 => 4}
          ]
      }
    end

    it "fixes key that have a nested array of hashes as value" do
      res = fix_array_of_hashes(
          'a' => {
              'b' => [
                  {1 => 2},
                  {3 => 4}
              ]
          }
      )

      res.should == {
          'a' => {
              'b' => {
                  '' => [
                      {1 => 2},
                      {3 => 4}
                  ]
              }
          }
      }
    end
  end
end
