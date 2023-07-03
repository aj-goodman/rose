require 'simplecov'
SimpleCov.start
require File.join(File.dirname(__FILE__), 'gilded_rose')
#
# Adam Goodman
# SWE 6733
# Kennesaw State University - Summer 2023
#
describe GildedRose do

  describe "#update_quality" do
    before :each do
      @base_quality = 10
      @base_item = Item.new("item", 1, @base_quality)
      @items = [@base_item]
    end

    it "does not change the name" do
      GildedRose.new(@items).update_quality
      expect(@items[0].name).to eq "item"
    end

    context "the sell by date has passed" do
      before :each do
        @after_sell = Item.new("after", -1, @base_quality)
        @items << @after_sell
      end

      it "degrades quality twice as fast" do
        GildedRose.new(@items).update_quality
        delta = (@base_quality - @items.last.quality)/(@base_quality - @items[0].quality)
        expect(delta).to eq 2
      end
    end

    context "the item is conjured" do
      before :each do
        @conjure = Item.new("Conjure", 10, @base_quality)
        @items << @conjure
      end

      it "degrades quality twice as fast" do
        GildedRose.new(@items).update_quality
        delta = (@base_quality - @items.last.quality)/(@base_quality - @items[0].quality)
        expect(delta).to eq 2
      end
    end

    context "the item is Aged Brie OR backstage passes" do
      before :each do
        @ab = Item.new("Aged Brie", 1, @base_quality)
        @bp = Item.new("Backstage passes to a TAFKAL80ETC concert", 1, @base_quality)
        @items = [@ab, @bp]
      end

      it "increases in quality as it ages" do
        GildedRose.new(@items).update_quality
        expect(@items[0].quality).to be > @base_quality
        expect(@items[1].quality).to be > @base_quality
      end

      context "the quality is >= 50" do
        it "does not allow quality to surpass 50" do
          @items[0].quality = 50
          GildedRose.new(@items).update_quality
          expect(@items[0].quality).to eq 50
        end
      end

      context "the item is a backstage pass" do
        context "there are <= 10 days until the concert" do
          before :each do
            @items[1].sell_in = 9
            GildedRose.new(@items).update_quality
          end
          it "increased in quality by 2" do
            expect(@items[1].quality).to eq @base_quality + 2
          end
        end

        context "there are <= 5 days until the concert" do
          before :each do
            @items[1].sell_in = 4
            GildedRose.new(@items).update_quality
          end
          it "increased in quality by 3" do
            expect(@items[1].quality).to eq @base_quality + 3
          end
        end

        context "the concert has passed" do
          before :each do
            @items[1].sell_in = -1
            GildedRose.new(@items).update_quality
          end
          it "reduced quality to zero" do
            expect(@items[1].quality).to eq 0
          end
        end
      end
    end

    it "does not allow for quality < 0" do
      @base_item.quality = 0
      GildedRose.new(@items).update_quality
      expect(@base_item.quality).to be >= 0
    end

    context "the quality is <= 50" do
      it "decreases the quality by one" do
        GildedRose.new(@items).update_quality
        expect(@base_item.quality).to eq @base_quality - 1
      end
    end

    context "and the item is Sulfuras" do
      before :each do
        @sell_in = 10
        @items = [Item.new("Sulfuras, Hand of Ragnaros", @sell_in, @base_quality)]
        GildedRose.new(@items).update_quality
      end
      it "never has to be sold" do
        expect(@items[0].sell_in).to eq @sell_in
      end

      it "never deceases in quality" do
        expect(@items[0].quality).to eq @base_quality
      end
    end
  end
end

describe Item do
  describe "to_s" do
    it "returns the Name, Sell In, and Quality as a string" do
      item = Item.new("item", 1, 2)
      expect(item.to_s).to eq "item, 1, 2"
    end
  end
end
