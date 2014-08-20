require File.expand_path('../../spec_helper', __FILE__)
include RightApi::Helper

describe RightApi::Helper, :unit=>true do

  API_MEDIA_TYPES = %w{audit_entry ip_address process server}

  context ".define_instance_method" do
    it "should define method" do
      flexmock(RightApi::Helper).should_receive(:define_method)
      define_instance_method('show') {1}
    end
  end

  context ".api_methods" do
    it "should return api methods" do
      api_methods.should == RightApi::Helper.methods(false)
    end
  end

  context ".has_id" do
    it "should return false when params have no :id" do
      params = {}
      has_id(params).should == false
    end

    it "should return true when params have no :id" do
      params = {:id => 1}
      has_id(params).should == true
    end
  end

  context ".add_id_and_params_to_path" do
    it "should add id to the path" do
      path = "/api/hello"
      params = {:id => 1}
      result = "/api/hello/1"
      add_id_and_params_to_path(path,params).should == result
    end

    it "should add params to the path" do
      path = "/api/hello"
      params = {:right => "scale"}
      result = "/api/hello?right=scale"
      add_id_and_params_to_path(path,params).should == result
    end

    it "should add filters to the path" do
      path = "/api/hello"
      params = {:filter => ["first_name==Right", "last_name==Scale"]}
      result = "/api/hello?filter[]=first_name%3D%3DRight&filter[]=last_name%3D%3DScale"
      add_id_and_params_to_path(path,params).should == result
    end

    it "should add id/params/filters to the path" do
      path = "/api/hello"
      params = {
        :id     => 1,
        :param  => "params",
        :filter => ["first_name==Right", "last_name==Scale"]
      }
      result = "/api/hello/1?filter[]=first_name%3D%3DRight&filter[]=last_name%3D%3DScale&param=params"
      add_id_and_params_to_path(path,params).should == result
    end
  end

  context ".insert_in_path" do
    it "should insert term in front of first ? in path" do
      path = "aa?bb?cc?dd???"
      term = "term"
      result = "aa/term?bb?cc?dd???"
      insert_in_path(path,term).should == result
    end

    it "should append term to the end of path" do
      path = "helloThisIsAPath"
      term = "term"
      result = "helloThisIsAPath/term"
      insert_in_path(path,term).should == result
    end
  end

  context ".is_singular?" do
    API_MEDIA_TYPES.each do |media_type|
      it "should identify media type #{media_type} as singular" do
        is_singular?(media_type).should == true
      end
    end
  end

  context ".get_href_from_links" do
    it "should return nil for empty links" do
      links = []
      get_href_from_links(links).should == nil
    end

    it "should return href of self link" do
      links = [
        {"rel" => "network", "href" => "/api/networks/aaa"},
        {"rel" => "self", "href" => "/api/self"}
      ]
      get_href_from_links(links).should == "/api/self"

      links.should == [
                       {"rel" => "network", "href" => "/api/networks/aaa"},
                       {"rel" => "self", "href" => "/api/self"}
                      ]
    end
  end

  context ".get_and_delete_href_from_links" do
    it "should return nil for empty links " do
      links = []
      get_and_delete_href_from_links(links).should == nil
    end

    it "should return and delete href of self link from links" do
      links = [
        {"rel" => "network", "href" => "/api/networks/aaa"},
        {"rel" => "self", "href" => "/api/self"}
      ]
      get_and_delete_href_from_links(links).should == "/api/self"

      links.should == [{"rel" => "network", "href" => "/api/networks/aaa"}]
    end
  end

  context ".simple_singularize" do
    it "should return hardcoded values for special words" do
      pair = {
        "audit_entries" => "audit_entry",
        "ip_addresses" => "ip_address",
        "processes" => "process"
      }
      pair.keys.each do |key|
        simple_singularize(key).should == pair[key]
      end
    end

    it "should return choped word for general work" do
      word = "RightScale"
      simple_singularize(word).should == word.chop
    end
  end

  context ".get_singular" do
    it "should return downcased singular form of word" do
      word = "RightScale"
      get_singular(word).should == simple_singularize(word.to_s.downcase)
    end
  end

  context ".fix_array_of_hashes" do
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
