require 'prawn/core'
require 'prawn/layout'
require 'pdf_report'
require 'timecards_helper'
class TimecardPdfReport
  include TimecardsHelper
  attr_accessor :timecards, :sub_header

  def initialize(timecards, user_name, localData )
    @timecards = timecards
    @user_name = user_name
    @localData =  localData
  end

  def create_report
    timecards_arr = get_arr

    pdf_report = PdfReport.new
    pdf_report.set_report_header( @localData['timecard_report'], @localData['created_by'] + @user_name + ')', @sub_header)
    pdf = pdf_report.get_pdf

    # body
    pdf.move_down(20)
    pdf.text @localData['total_bill_hours'] + Utils.get_time_from_seconds(get_bill_hours), :align => :left, :size => 9
    pdf.text @localData['total_no_of_timecards'] + @timecards.length.to_s, :align => :left, :size => 9

    headers = [
               Prawn::Table::Cell.new(:position => [0, 0], :text => @localData['work_date'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 1], :text => @localData['work_hour'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 2], :text => @localData['unit'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 3], :text => @localData['client'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 4], :text => @localData['matter'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 5], :text => @localData['timekeeper'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 6], :text => @localData['bill_status'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 7], :text => @localData['description'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 8], :text => @localData['internal_comment'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 9], :text => @localData['user'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 10], :text => @localData['status'], :font_style => :bold, :font_size => 8)
    ]

    pdf.move_down(10)
    pdf.table timecards_arr, :border_style => :grid, :border_width => 0.1, :border_color => "C4C4C4",
              :headers => headers,
              :header_color => "E2E2E2", :header_text_color => "000000", :align_headers => :center,
              :align => {0=>:center, 1=>:center, 2=>:center, 3=>:left, 4=>:left, 5=>:left, 6=>:left, 7=>:left, 8=>:left, 9=>:center, 10=>:left},
              :column_widths => {0=>70, 1=>45, 2=>30, 3=>95, 4=>95, 5=>95, 6=>80, 7=>80, 8=>80, 9=>55, 10=>55},
              :font_size => 8, :position => :center

    pdf_report.set_page_footer
    pdf_report.set_report_footer

    return pdf.render
  end

  def create_week_report
    timecards_arr = get_week_arr

    pdf_report = PdfReport.new
    pdf_report.set_report_header( @localData['timecard_report'], @localData['created_by'] + @user_name + ')', @sub_header)
    pdf = pdf_report.get_pdf

    # body
    pdf.move_down(20)
    pdf.text("Sorted by Date", :align => :center, :size => 18)
    pdf.text(@localData['total_bill_hours'] + Utils.get_time_from_seconds(get_bill_hours), :align => :left, :size => 9)
    pdf.text(@localData['total_no_of_timecards'] + @timecards.length.to_s, :align => :left, :size => 9)

    headers = [
               Prawn::Table::Cell.new(:position => [0, 0], :text => @localData['work_date'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 1], :text => @localData['work_hour'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 2], :text => @localData['timekeeper'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 3], :text => @localData['description'], :font_style => :bold, :font_size => 8)
    ]

    pdf.move_down(10)
    pdf.table(sort_arr_by_date_then_name(timecards_arr), :border_style => :grid, :border_width => 0.1, :border_color => "C4C4C4",
              :headers => headers,
              :header_color => "E2E2E2", :header_text_color => "000000", :align_headers => :center,
              :align => {0=>:center, 1=>:center, 2=>:left, 3=>:left},
              :column_widths => {0=>70, 1=>45, 2=>120, 3=>500},
              :font_size => 8, :position => :center)
    
    pdf.start_new_page
    
    pdf.text("Summary (Date)", :align => :center, :size => 18)
    
    date_headers = [
               Prawn::Table::Cell.new(:position => [0, 0], :text => @localData['work_date'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 1], :text => @localData['work_hour'], :font_style => :bold, :font_size => 8),
    ]

    pdf.table(sum_hours_by_date(timecards_arr), :border_style => :grid, :border_width => 0.1, :border_color => "C4C4C4",
              :headers =>  date_headers,
              :header_color => "E2E2E2", :header_text_color => "000000", :align_headers => :center,
              :align => {0=>:center, 1=>:center},
              :column_widths => {0=>70, 1=>45},
              :font_size => 8, :position => :center)
    pdf.start_new_page

    pdf.text("Sorted by Name", :align => :center, :size => 18)

    pdf.table(sort_arr_by_name_then_date(timecards_arr), :border_style => :grid, :border_width => 0.1, :border_color => "C4C4C4",
              :headers => headers,
              :header_color => "E2E2E2", :header_text_color => "000000", :align_headers => :center,
              :align => {0=>:center, 1=>:center, 2=>:left, 3=>:left},
              :column_widths => {0=>70, 1=>45, 2=>120, 3=>500},
              :font_size => 8, :position => :center)

    pdf.start_new_page
    pdf.text("Summary (Name)", :align => :center, :size => 18)
    pdf.move_down(10)

    name_headers = [
               Prawn::Table::Cell.new(:position => [0, 0], :text => @localData['timekeeper'], :font_style => :bold, :font_size => 8),
               Prawn::Table::Cell.new(:position => [0, 1], :text => @localData['work_hour'], :font_style => :bold, :font_size => 8),
    ]

    pdf.table(sum_hours_by_name(timecards_arr), :border_style => :grid, :border_width => 0.1, :border_color => "C4C4C4",
              :headers =>  name_headers,
              :header_color => "E2E2E2", :header_text_color => "000000", :align_headers => :center,
              :align => {0=>:left, 1=>:center},
              :column_widths => {0=>120, 1=>45},
              :font_size => 8, :position => :center)

    pdf_report.set_page_footer
    pdf_report.set_report_footer

    return pdf.render
  end

  private
  
  def get_arr
    if @timecards.nil? || @timecards.length == 0
      timecards_arr = Array.new(1) { Array.new(11) }
    else
      timecards_arr = Array.new(@timecards.length) { Array.new(11) }
      i=0
      @timecards.each do |k, v|
        timecards_arr[i][0] = v.date
        timecards_arr[i][1] = Utils.get_time_from_seconds( Utils.get_bill_hours_from_work_hours(v.hours, v.units ) )
        timecards_arr[i][2] = get_units_value_formatted(v.units)
        timecards_arr[i][3] = Utils.get_display_name( v.client_name , v.client_number )
        timecards_arr[i][4] = Utils.get_display_name( v.matter_name , v.matter_number )
        timecards_arr[i][5] = Utils.get_display_name( v.timekeeper_name , v.timekeeper_number)
        timecards_arr[i][6] = v.bill_status
        timecards_arr[i][7] = v.description
        timecards_arr[i][8] = v.internal_comment
        timecards_arr[i][9] = v.user_name
        timecards_arr[i][10] = v.approved=='yes' ? @localData['posted'] : (v.posted=='yes' ? @localData['synced'] : @localData['not_synced'] )
        i+=1
      end
    end
    timecards_arr
  end
  
  def get_week_arr
    if @timecards.nil? || @timecards.length == 0
      timecards_arr = Array.new(1) { Array.new(4) }
    else
      timecards_arr = Array.new(@timecards.length) { Array.new(4) }
      i = 0
      @timecards.each do |k, v|
        timecards_arr[i][0] = v.date
        timecards_arr[i][1] = Utils.get_time_from_seconds(Utils.get_bill_hours_from_work_hours(v.hours, v.units))
        timecards_arr[i][2] = Utils.get_display_name(v.timekeeper_name , v.timekeeper_number)
        timecards_arr[i][3] = v.description
        i+=1
      end
    end
    timecards_arr
  end


  def sum_hours_by_date(timecards_arr)
    date_hash = Hash.new(0)

    i = 0

    timecards_arr.each do
      date_hash[timecards_arr[i][0]] += Utils.get_seconds_from_time(timecards_arr[i][1])
      i += 1
    end

    i = 0

    timecards_arr.each do
    #  date_hash[timecards_arr[i][0]] = Utils.get_time_from_seconds(date_hash[timecards_arr[i][0]])
      i += 1
    end

    arr = date_hash.map { |k, v| [k, Utils.get_time_from_seconds(v)] }

    arr.sort { |a, b| a[0] <=> b[0]}
  end

  def sum_hours_by_name(timecards_arr)
    name_hash = Hash.new(0)

    i = 0

    timecards_arr.each do
      name_hash[timecards_arr[i][2]] += Utils.get_seconds_from_time(timecards_arr[i][1])
      i += 1
    end

    i = 0

    timecards_arr.each do
    #  date_hash[timecards_arr[i][0]] = Utils.get_time_from_seconds(date_hash[timecards_arr[i][0]])
      i += 1
    end

    arr = name_hash.map { |k, v| [k, Utils.get_time_from_seconds(v)] }

    arr.sort { |a, b| a[0] <=> b[0]}
  end

  def sort_arr_by_date_then_name(timecards_arr)
    timecards_arr.sort { |a, b| a[0].to_s + a[2].to_s.split(' - ')[1] <=> b[0].to_s + b[2].to_s.split(' - ')[1] }
  end

  def sort_arr_by_name_then_date(timecards_arr)
    timecards_arr.sort { |a, b| a[2].to_s.split(' - ')[1] + a[0].to_s <=> b[2].to_s.split(' - ')[1] + b[0].to_s}
  end


  def get_bill_hours
    total_bill_hours = 0

    @timecards.each do |k, v|
      total_bill_hours += v.hours.to_i
    end

    total_bill_hours
  end
end