require 'spec_helper'

describe Item do
  
  let(:item) { FactoryGirl.create(:item) }

  describe "mark_complete" do
    
    it "marks the item completed" do
      expect{ item.mark_complete }
        .to change{ item.completed }
        .to true
    end
  end

end
