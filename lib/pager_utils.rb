
#developed by Wasiqul Islam at July 11, 2011

module PagerUtils


  def self.get_page_data(
   current_page,
   total_records,
   page_size
  )

   pages = []
   pages_before = []
   pages_after = []
   records_from  = 0
   records_to = 0

   if total_records == 0
       return pages_before, pages_after, records_from, records_to
   end

   total_pages = ( (total_records * 1.0) / page_size ).ceil.to_i
   if( current_page < 1 || current_page > total_pages )
     raise "Invalid page number, must be between 1 and " + total_pages.to_s
   end

   if( total_pages > 1 )
      pages.push( 1 )
      if( ( total_pages / 10 ) > 15000 )
          offset = -( total_pages / 10 )
          if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
              pages.push( ( current_page + offset ) )
          end
      end
      offset = -10000
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = -1000
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = -100
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = -10
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = -9
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = -8
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = -7
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = -6
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = -5
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = -4
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = -3
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = -2
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = -1
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      #-----------
      pages.push( current_page )
      #-----------
      offset = 1
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = 2
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = 3
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = 4
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = 5
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = 6
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = 7
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = 8
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = 9
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = 10
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = 100
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = 1000
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      offset = 10000
      if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
          pages.push( ( current_page + offset ) )
      end
      if( ( total_pages / 10 ) > 15000 )
          offset = ( total_pages / 10 )
          if( current_page + offset ) > 1 && ( current_page + offset ) < total_pages
              pages.push( ( current_page + offset ) )
          end
      end
      pages.push( total_pages )

      last_added_page = 0
      before = true
      pages.each do |pageNo|
        if( pageNo != last_added_page )
          if( pageNo != current_page )
             if before
               pages_before.push( pageNo )
               last_added_page = pageNo
             else
               pages_after.push( pageNo )
               last_added_page = pageNo
             end
          else
            before = false
          end
        end
      end

   end

   if( ( ( current_page ) * page_size ) < total_records )
     records_from = ( current_page -1 ) * page_size + 1
     records_to = ( current_page ) * page_size
   else
     records_from = ( current_page -1 ) * page_size + 1
     records_to = total_records
   end

   pages.clear
   return pages_before, pages_after, records_from, records_to

  end

end