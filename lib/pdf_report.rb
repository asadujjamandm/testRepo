require 'prawn/core'
require 'prawn/layout'
class PdfReport
  @@page_size = 'A4'
  @@page_layout = :landscape
  @@font = 'Helvetica'
  @@logo = "#{RAILS_ROOT}/public/images/report_logo.png"
  @@line_color = 'C4C4C4'
  @@header_font_size = 20
  @@footer_font_size = 8
  @@footer_text = "Auto generated report by WIPTime at '" + Time.now().strftime('%m-%d-%Y %H:%M:%S') + "'"

  def initialize
    @pdf = Prawn::Document.new :page_size => @@page_size, :page_layout => @@page_layout
    @pdf.font @@font
    logo = @@logo
    @pdf.image logo, :at => [@pdf.bounds.left, @pdf.bounds.top+10], :scale => 1
    @pdf.stroke_color @@line_color
  end

  def get_pdf
    @pdf
  end

  def set_report_header(header, sub_header1, sub_header2)
    @pdf.bounding_box [@pdf.bounds.left, @pdf.bounds.top], :width => @pdf.bounds.width do
      @pdf.text header, :align => :center, :size => @@header_font_size
      @pdf.text sub_header1, :align => :center, :size => @@footer_font_size
      if !sub_header2.nil? && sub_header2 != ''
        @pdf.text sub_header2, :align => :center, :size => @@footer_font_size
      else
        @pdf.move_down(8)
      end
      @pdf.stroke_horizontal_rule
    end
  end

  def set_page_footer
    @pdf.page_count.times do |i|
      @pdf.go_to_page(i+1)
      @pdf.bounding_box [@pdf.bounds.left, @pdf.bounds.bottom], :width => @pdf.bounds.width, :height => 15 do
        @pdf.move_down(5)
        @pdf.text "Page #{i+1} of #{@pdf.page_count}", :align => :right, :size => @@footer_font_size
      end
    end
  end

  def set_report_footer
    @pdf.bounding_box [@pdf.bounds.left, @pdf.bounds.bottom], :width => @pdf.bounds.width, :height => 15 do
      @pdf.stroke_horizontal_rule
      @pdf.move_down(5)
      @pdf.text @@footer_text, :align => :center, :size => @@footer_font_size
    end
  end
end