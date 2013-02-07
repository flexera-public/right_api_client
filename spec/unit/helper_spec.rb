require File.expand_path('../../spec_helper', __FILE__)
include RightApi::Helper

describe RightApi::Helper do

  context "#fix_array_of_hashes" do
    it "should fix all the keys that have the value as array of hashes" do
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

    it "should recursively fix all the keys that have the value as array of hashes " do
      res = fix_array_of_hashes(
        'a' => {
          'b' => [
            {1 => 2},
            {3 => 4}
          ],
          'c' => {
            'd' => [
              {5 => 6},
              {7 => 8}
            ]
          }
        }
      )

      res.should == {
        'a' => {
          'b[]' => [
            {1 => 2},
            {3 => 4}
          ],
          'c' => {
            'd[]' => [
              {5 => 6},
              {7 => 8}
            ]
          }
        }
      }
    end

  end
end
