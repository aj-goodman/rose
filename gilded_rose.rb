class GildedRose

  def initialize(items)
    @items = items
  end

  def update_quality
    @items.each do |item|
      expired = item.sell_in.negative?
      delta = 1
      name = item.name.downcase
      quality = item.quality
      sell_in = item.sell_in

      case
      when name.include?("aged brie")
        item.quality += delta unless quality >= 50
      when name.include?("backstage pass")
        (item.quality = 0) and next if expired
        unless sell_in > 10
          delta = (0..5).include?(sell_in) ? 3 : 2
        end
        item.quality += delta
      when name.include?("sulfura")
        next
      else
        next if quality == 0
        delta += delta if expired || name.include?("conjure")
        item.quality -= delta
      end
    end
  end
end

class Item
  attr_accessor :name, :sell_in, :quality

  def initialize(name, sell_in, quality)
    @name = name
    @sell_in = sell_in
    @quality = quality
  end

  def to_s()
    "#{@name}, #{@sell_in}, #{@quality}"
  end
end
