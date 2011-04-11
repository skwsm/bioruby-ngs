#
#  
#
# Copyright:: Copyright (C) 2011
#     Francesco Strozzi <francesco.strozzi@gmail.com>
# License:: The Ruby License
#
#

require 'rubyvis'

module Bio
  module Ngs
    class Graphics
      
        def self.draw_area(data,width,height,out=nil)
          point = 0
          max = data.max + 10
          data = data.map do |d|
            point += 1
            OpenStruct.new({:x=> point, :y=> d})
          end
          x = pv.Scale.linear(data, lambda {|d| d.x}).range(0, width)
          y = pv.Scale.linear(0, max).range(0, height);
          
          #The root panel
          vis = pv.Panel.new() do
            width width
            height height
            bottom 20
            left 20
            right 10
            top 5

          # Y-axis and ticks
            rule do
              data y.ticks(10)
              bottom(y)
              stroke_style {|d| d!=0 ? "#eee" : "#000"}
              label(:anchor=>"left") {
                text y.tick_format
              }
            end

          # X-axis and ticks.
            rule do
              data x.ticks()
              visible {|d| d!=0}
              left(x)
              bottom(-5)
              height(5)
              label(:anchor=>'bottom') {
                text(x.tick_format)
              }
            end
            
          #/* The area with top line. */
            area do |a|
              a.data data
              a.bottom(1)
              a.left {|d| x.scale(d.x)}
              a.height {|d| y.scale(d.y)}
              a.fill_style("rgb(121,173,210)")
              a.line(:anchor=>'top') {
                line_width(3)
              }
            end
          end
          
          # panel legend and title
          panel = vis.add(Rubyvis::Panel).
            width(width-15).
            height(height)
            
          panel.anchor('top').add(Rubyvis::Label).
            font("20px sans-serif").
            text("FastQ Qualities")
          
          panel.anchor('bottom').add(Rubyvis::Label).text("Nucleotide")
          panel.anchor('left').add(Rubyvis::Label).
            text_angle(1.5*Math::PI).
            text("Quality Score")
          
          
          vis.render();
          
          if out
            File.open(out,"w") {|f| f.write(vis.to_svg) }
          else
            puts vis.to_svg
          end

      end
      
      def self.bubble_chart(fileout,dataset = {}, panel_w = 600, panel_h = 800)
        puts dataset.inspect
        colors=Rubyvis::Colors.category10()
        c=Rubyvis::Colors.category10().by(lambda {|n| n.parent_node})

        vis = Rubyvis::Panel.new
        .width(panel_w-10)
        .height(panel_h-10)
        .bottom(5)
        .left(5)
        .right(5)
        .top(5)

        root=Rubyvis::Dom::Node.new
        dataset.each_pair do |name,value|
          child = Rubyvis::Dom::Node.new(value)
          child.node_name = name
          root.append_child(child)
        end
        root = root.nodes()

        pack=vis.add(pv.Layout.Pack).
        nodes(root).
        size(lambda {|n| n.node_value})

        pack.node.add(Rubyvis::Dot).
        visible( lambda {|n| n.parent_node}).
        fill_style(lambda {|n|
          colors.scale(n.parent_node).
          brighter((n.node_value) / 5.0)
          }).
          stroke_style(c)

          pack.node_label.add(Rubyvis::Label).
          visible( lambda {|n| n.parent_node}).
          text(lambda {|n| n.node_name})
        vis.render()
        File.open(fileout,"w") {|f| f.write vis.to_svg+"\n"}
      end
  
    end
  end
end