#Developed by Wasiqul Islam at May 04, 2011
#Modified by Wasiqul Islam at May 08, 2011

require 'exceptions'

class LocalizationController  < ApplicationController

  include ActionView::Helpers::NumberHelper

  def get_login
    session[:remember_token][SESSION_LOGIN_INDEX]
  end

  def get_pwd
    session[:remember_token][SESSION_PASSWORD_INDEX]
  end

  def get_localized_text( text_to_display, is_forward_conversion )

    localized_data = get_ordered_localized_data(is_forward_conversion )

    return text_to_display if localized_data.nil?   #return exatly what it was
    
    i = 0
    total = localized_data.count
    localized_data.each do |k, v|
      index = v.key.index(' ')

      if index.nil?
        # if key is a word(key is a word if it contains no space character)
        text_to_display = replace_all_words(text_to_display, v.key, v.value)
      else #key is a sentence
			  text_to_display = v.value if v.key.downcase == text_to_display.downcase #i, e value
      end
    end

    return text_to_display

  end

  def get_localized_date(date_to_display)
    return '' if date_to_display.nil?
    session['date_format'].nil? ? date_to_display.strftime('%b %d, %Y') : date_to_display.strftime('' + session['date_format'])
  end

  def get_localized_time(time_to_display)
    return '' if time_to_display.nil?
    return time_to_display.strftime('' + session['time_format'])
  end

  def get_localized_time_h_m(time_to_display)
    return '' if time_to_display.nil?
    return time_to_display.strftime('%I:%M %p')
  end

  # Converts a localized date string into a default(year-month-day format) date string.
  def get_date_as_string(date_to_parse)
    date1 = DateTime.strptime(date_to_parse, session['date_format'])
    return date1.strftime('%Y-%m-%d')
  end

  # Converts a localized time string into a default time(24hour format) string.
  def get_time_as_string(time_to_parse)
    session['time_format'].index('%p').nil? ? time1 = DateTime.strptime(time_to_parse, '%H:%M:%S') : time1 = DateTime.strptime(time_to_parse, '%I:%M:%S %p')

    return time1.strftime('%H:%M:%S')
  end

  def get_localized_number( number_to_display )

    #Ruby number conversion:
    #first install using the command as follows:
    #gem install money
    #then include the class as required
    #include ActionView::Helpers::NumberHelper
    #then you can use the following command
    #number_with_delimiter(12345678.05, :locale => :fr)
    #number_with_delimiter(12345678.05, :locale => :en)

    locality = session['number_format']
    return number_with_delimiter(number_to_display , :locale => locality.to_sym)

  end


  #load localized data from database and store it into session
  def load_localized_data

    begin

      #load user's locality information from database
      localityID         = '1'
      date_format        = ''
      time_format        = ''
      number_format      = ''
      calendar_start_day = ''
      timecard_unit      = '60'
      localityID, date_format, time_format, number_format, calendar_start_day, timecard_unit = NsiServices.get_user_locality_info(NsiServices.get( NSI_SERVICE_USER_LOCALITY, {'userid' => get_login, 'password' => get_pwd} ), false)
      
      raise 'user locality data error' if localityID.nil?
      
      javascript_date_format             = convert_date_format_to_javascript date_format
      session['javascript_date_format']  = javascript_date_format

      session['javascript_time_24_hour'] = time_format.index('tt').nil? ?  'true' : 'false'
      
      date_format                        = convert_date_time_format_to_ruby(date_format)
      time_format                        = convert_date_time_format_to_ruby(time_format)
      session['date_format']             = date_format  #'%d/%m/%Y'#'%Y-%m-%d %H:%M:%S'
      session['time_format']             = time_format
      session[ 'number_format' ]         = number_format #'fr'
      session[ 'calendar_start_day' ]    = calendar_start_day #'1'
      session[ 'timecard_unit' ]         = timecard_unit


      postdata                     = make_post_data_for_localization('true')
      session['all_data']          = NsiServices.get_localized_data(NsiServices.get(NSI_SERVICE_LOCALIZATION_DATA, {'userid' => get_login, 'password' => get_pwd}, postdata))
      postdata                     = make_post_data_for_localization('false')
      session['all_reversed_data'] = NsiServices.get_localized_data(NsiServices.get(NSI_SERVICE_LOCALIZATION_DATA, {'userid' => get_login, 'password' => get_pwd}, postdata))

    rescue Exceptions::ServiceNotAuthorized => exception
      log_exception_text('Locale data not loaded: ' + GENERIC_NON_AUTHORIZED_MESSAGE)
      flash.now[:fatalerror]              = get_localized_text(GENERIC_NON_AUTHORIZED_MESSAGE, true)
      session['all_data']                 = {}
      session['all_reversed_data']        = {}
      session['javascript_date_format']   = 'yy-mm-dd'
      session['javascript_time_24_hour']  = 'true'
      session['date_format']              = '%Y/%m/%d'
      session['time_format']              = '%H:%M:%S'
      session['number_format']            = 'en'
      session['calendar_start_day']       = '1'
      session['timecard_unit']            = '60'  #60 seconds default

    rescue Exception => e
      log_exception_text('Locale data not loaded: ' + e.message)
      flash.now[:fatalerror]             = GENERIC_FATAL_ERROR_MESSAGE
      session['all_data']                = {}
      session['all_reversed_data']       = {}
      session['javascript_date_format']  = 'yy-mm-dd'
      session['javascript_time_24_hour'] = 'true'
      session['date_format']             = '%Y/%m/%d'
      session['time_format']             = '%H:%M:%S'
      session['number_format']           = 'en'
      session['calendar_start_day']      = '1'
      session['timecard_unit']           = '60'  #60 seconds default
    end
  end

  :private
  # Here data type of localizedData may vary on programming language
  # Here ordering of localized data will be done in ascending way by
  # The length of values of the localized data
  # ;ength( key )
  # For reversed conversion all the keys are treated as values and all the values are treated as keys
  
  def get_ordered_localized_data(is_forward_conversion)
    return is_forward_conversion ? session['all_data'] : session['all_reversed_data']
  end

  #word replacement method(batch)
  def replace_all_words(text_to_replace, key, value)
    search_index             = -1
    current_index            = 0
    current_word             = ''
    current_replacement_type = 0

    # 0 = all small, 1 = initial caps(capital letter), 2 = all caps. 3 types are supported

    loop do   # infinite loop

      search_index = find_word(text_to_replace, current_index, key)

		  # breaks the loop when applicable
		  break if search_index == -1

      current_word             = text_to_replace[search_index, key.length]
      current_replacement_type = get_replacement_type(current_word)

      current_word =
          case current_replacement_type
          when 0
            value.downcase
          when 1
            value[0].upcase +  value[1, value.length-1].downcase
          else
            value.upcase
          end

      # update currentIndex for next loop
      current_index = search_index + current_word.length

      # replace the text appropriately
      text_to_replace = text_to_replace[0, search_index] + current_word +
          text_to_replace[search_index + key.length, text_to_replace.length - (search_index + key.length)]

    end

    text_to_replace

  end

  #returns the replacement type
  #0 = all small, 1 = initial caps(capital letter), 2 = all caps. 3 types are supported
  def get_replacement_type(sample_word)
    
    return 0 if sample_word.nil? || sample_word.length == 0
 
    if sample_word.length == 1
      return is_upper_case?(sample_word[0]) ? 1 : 0
    end

    if is_upper_case?(sample_word[1])
		  return 2
		elsif is_upper_case?(sample_word[0])
		  return 1
		else
		  return 0
    end

  end

  # method used to find an exact word
  # this method is recursive
  def find_word(full_text, starts_from_index, search_key)

    return -1 if starts_from_index >= full_text.length  #-1 indicates that searched word is not found
    
    search_index = full_text.downcase.index(search_key.downcase, starts_from_index)

    return -1 if search_index.nil?

    search_index_length = search_index + search_key.length

    # If this is a word at the last end of the string then
    return search_index if (search_index_length) == full_text.length

    # check if the (search_index+search_key.length())th character is an alphabet
    # if its an alphabet then the searched word is not an exact word
    # for example if “no” is searched in “not” then the character
    # after “no” is “t”. Its an alphabet. So “no” is not an exact word.
    # actual word is “not”
    # in this case: skip and find again
    
    full_text[search_index_length].to_s if full_text[search_index_length].is_a?(Fixnum)

    next_character = '' + full_text[search_index_length]


    return is_delimiter(next_character) ? search_index : find_word(full_text, search_index_l, search_key)
  end

  #method is_delimiter
  #algorithm of this method may change for performance issue if needed
  #hashing can be used
  #test_string should contain only one character
  def is_delimiter(test_string)

    delimeter_list = [' ', ',', '}', '{', '(', ')', ';', '.', '[', ']', '*', '#', '@', '!', '%', '+', '&', '"', "'", '\\', '/', 
                      '-', '_', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', ':', '|', '`', '~', '=', '$', '^', '?']

    delimeter_list.each do |delimiter|
      return true if delimiter == test_string
    end

    return false

  end

  # method is_upper_case?
  def is_upper_case?(test_string)

    return false if test_string.is_a?(Fixnum)
    
    test_string.upcase == test_string
    
  end

  def make_post_data_for_localization(isForward)
    postdata = {}
    postdata.merge!({'isForward' => isForward})
    postdata
  end

  def convert_date_time_format_to_ruby( standard_date_format )

    #to_convert must be arranged to descending order of the string length of key
    to_convert = {}
    to_convert.merge!({'MMMM' => '%B'})
    to_convert.merge!({'MMM'  => '%b'})
    to_convert.merge!({'MM'   => '%m'})
    to_convert.merge!({'dddd' => '%A'})
    to_convert.merge!({'ddd'  => '%a'})
    to_convert.merge!({'dd'   => '%d'})
    to_convert.merge!({'yyyy' => '%Y'})
    to_convert.merge!({'yy'   => '%y'})
    to_convert.merge!({'HH'   => '%H'})
    to_convert.merge!({'hh'   => '%I'})
    to_convert.merge!({'mm'   => '%M'})
    to_convert.merge!({'ss'   => '%S'})
    to_convert.merge!({'tt'   => '%p'})

    to_convert.each do |k, v|
       standard_date_format = standard_date_format.gsub(k, v)
    end

    standard_date_format

  end

  def convert_date_format_to_javascript( standard_date_format )

    #to_convert must be arranged to descending order of the string length of key
    #have to change the algorithm if textual date is to be supported
    #for example: day 5 of May in the year 2011
    #url link reference: http://jqueryui.com/demos/datepicker/#date-formats
    to_convert = {}
    to_convert.merge!({' '     => "' '"})
    to_convert.merge!({'MMMM'  => 'MM'})
    to_convert.merge!({'MMM'   => 'M'})
    to_convert.merge!({'MM'    => 'm'})
    to_convert.merge!({'dddd'  => 'DD'})
    to_convert.merge!({'ddd'   => 'D'})
    to_convert.merge!({'dd'    => 'd'})
    to_convert.merge!({'yyyy'  => "'aaa'"})
    to_convert.merge!({'yy'    => 'y'})
    to_convert.merge!({"'aaa'" => 'yy'})
    #not needed, only date is acceptable, not time
    #to_convert.merge!( { "HH" => "%H" } )
    #to_convert.merge!( { "hh" => "%I" } )
    #to_convert.merge!( { "mm" => "%M" } )
    #to_convert.merge!( { "ss" => "%S" } )
    #to_convert.merge!( { "tt" => "%p" } )

    to_convert.each do |k, v|
      standard_date_format = standard_date_format.gsub(k, v)
    end

    standard_date_format

  end

end


