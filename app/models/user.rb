require 'rubygems'
require 'neography'
require 'active_model'

class User 
  include ActiveModel::Model
  @neo = Neography::Rest.new
  attr_accessor :name, :node

  def self.all
    users = []
    response = @neo.execute_query("START n=node(*) WHERE n.type='user' RETURN n;")
    response["data"].each do |data|
      user = data[0]["data"]
      user["id"] = data[0]["self"].split('/').last
      users << user
    end
    users
  end

  def self.find(id)
    new(node: Neography::Node.load(id))
  end


  def save
    neo.create_node(name: name, type: 'user')
  end

  def neo
    @neo || Neography::Rest.new
  end

  def friends
    self.node.outgoing(:friends)
  end

  def self.add_friend(user_id, friend_id)
    friend = Neography::Node.load(friend_id)
    user = Neography::Node.load(user_id)
    @neo.create_relationship("friends", user, friend)
  end

  def unfriend(friend_id)
    neo.get_node_relationships(self.node, "out", "friends").each do |rel|
      if rel['end'].split('/').last  == friend_id
        neo.delete_relationship(rel['self'].split('/').last)
        break
      end
    end
  end

  def suggested_friends
    users, friend_ids = [], [self.node.neo_id.to_i]
    self.friends.each{|f| friend_ids << f.neo_id.to_i}
    response = neo.execute_query("START n=node(*) WHERE NOT (ID(n) IN #{friend_ids}) AND n.type='user' RETURN n;")
    response["data"].each do |data|
      user = data[0]["data"]
      user["id"] = data[0]["self"].split('/').last
      users << user
    end
    users
  end
end
