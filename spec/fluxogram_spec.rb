require 'rails_helper'

RSpec.describe Fluxogram do

  sample_fluxogram = Fluxogram.new

  before(:each) do
    sample_fluxogram.nodes = {}
    sample_fluxogram.connections = {}
    sample_fluxogram.params = {}
  end

  it "should add nodes" do
    sample_fluxogram.add_node :test, :test_step
    expect(sample_fluxogram.nodes).to eq({:test => :test_step})
    sample_fluxogram.add_node :test2, :test_step2
    expect(sample_fluxogram.nodes).to eq({:test => :test_step,
                              :test2 => :test_step2})
  end

  it "should add connections" do
    sample_fluxogram.add_node :test, :test_step
    sample_fluxogram.add_node :test2, :test_step2
    sample_fluxogram.add_node :test3, :test_step2
    sample_fluxogram.connect(:test, :test2, "bla")
    expect(sample_fluxogram.connections).to eq({:test => {"bla" => :test2}})
    sample_fluxogram.connect(:test3, :test, 4)
    expect(sample_fluxogram.connections).to eq({:test => {"bla" => :test2},
                                    :test3 => {4 => :test}})
    sample_fluxogram.connect(:test, :test3, true)
    expect(sample_fluxogram.connections).to eq({:test => {"bla" => :test2,
                                              true => :test3},
                                    :test3 => {4 => :test}})
  end

  it "should add parameters" do
    sample_fluxogram.add_node :test, :test_step, "bla"
    expect(sample_fluxogram.params).to eq({:test => "bla"})
  end

  it "should build tree correctly" do
    sample_fluxogram.start_node = :test1
    sample_fluxogram.add_node :test1, :test_step
    sample_fluxogram.add_node :test2, :test_step
    sample_fluxogram.add_node :test3, :test_step
    sample_fluxogram.add_node :test4, :test_step
    sample_fluxogram.connect :test1, :test2, true
    sample_fluxogram.connect :test1, :end, false
    sample_fluxogram.connect :test2, :test3, true
    sample_fluxogram.connect :test2, :test4, false
    sample_fluxogram.connect :test3, :end, "anything"
    sample_fluxogram.connect :test4, :end, "anything"
    sample_fluxogram.build_tree
    expect(sample_fluxogram.tree).to eq({:name=>:test1,
                             :step=>:test_step,
                             true=>{
                               :name=>:test2,
                               :step=>:test_step,
                               true=>{
                                 :name=>:test3,
                                 :step=>:test_step,
                                 "anything"=>{:name=>:end, :step=>nil}},
                               false=>{
                                 :name=>:test4,
                                 :step=>:test_step,
                                 "anything"=>{:name=>:end, :step=>nil}
                               }
                             },
                             false=>{:name=>:end, :step=>nil}})
  end
end
