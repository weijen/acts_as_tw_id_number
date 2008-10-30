module WeiJen
  module ActsAsTwIdNumber
    def self.included(base)
      base.extend ActMethods
    end
    
    module ActMethods
      def acts_as_tw_id_number(options={})
        options[:tw_id_number_column] ||= :tw_id_number
        
        unless included_modules.include? InstanceMethods
          class_inheritable_accessor :options
          extend ClassMethods
          include InstanceMethods
          
          validates_length_of options[:tw_id_number_column], :is => 10
          validates_presence_of options[:tw_id_number_column]
          validates_uniqueness_of options[:tw_id_number_column]
          validate :check_identity_number
        end
        
        self.options = options
      end
    end
    
    module ClassMethods
      INITIAL_LETTER_TO_NUMBER = {
        "A"=>"10", "B"=>"11", "C"=>"12", "D"=>"13", "E"=>"14", "F"=>"15",
        "G"=>"16", "H"=>"17", "I"=>"34", "J"=>"18", "K"=>"19", "L"=>"20",
        "M"=>"21", "N"=>"22", "O"=>"35", "P"=>"23", "Q"=>"24", "R"=>"25",
        "S"=>"26", "T"=>"27", "U"=>"28", "V"=>"29", "W"=>"32", "X"=>"30",
        "Y"=>"31", "Z"=>"33"
      }
      
      
      
      def is_identity_number?(id_number)
        id_number = id_number.upcase.strip
    
        return false unless id_number.length == 10
        return false unless /^[A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$/ =~ id_number
    
        initial_letter_number = INITIAL_LETTER_TO_NUMBER[id_number[0].chr]
    
        new_id_number = initial_letter_number + id_number[1,8]
   
        total = new_id_number[0].chr.to_i
        total += new_id_number[1].chr.to_i * 9
        total += new_id_number[2].chr.to_i * 8
        total += new_id_number[3].chr.to_i * 7
        total += new_id_number[4].chr.to_i * 6
        total += new_id_number[5].chr.to_i * 5
        total += new_id_number[6].chr.to_i * 4
        total += new_id_number[7].chr.to_i * 3
        total += new_id_number[8].chr.to_i * 2
        total += new_id_number[9].chr.to_i
    
        #puts total
        mod = total % 10
        check_number = (10 - mod) % 10
        return false if check_number != id_number[9].chr.to_i
        true
      end
    end
    
    module InstanceMethods
      def check_identity_number
        self.errors.add(self.class.options[:tw_id_number_column], "Taiwan Identify number error.") unless self.class.is_identity_number?(id_number_content)
      end
      
      def male?
        return true if id_number_content[1].chr == "1"
        false
      end
      
      def female?
        return true if id_number_content[1].chr == "2"
        false
      end
      
      def where_issued
        initial_letter_to_county = {
          "A"=>"台北市", "B"=>"台中市", "C"=>"基隆市", "D"=>"台南市", "E"=>"高雄市", "F"=>"台北縣",
          "G"=>"宜蘭縣", "H"=>"桃園縣", "I"=>"嘉義市", "J"=>"新竹縣", "K"=>"苗栗縣", "L"=>"台中縣",
          "M"=>"南投縣", "N"=>"彰化縣", "O"=>"新竹市", "P"=>"雲林縣", "Q"=>"嘉義縣", "R"=>"台南縣",
          "S"=>"高雄縣", "T"=>"屏東縣", "U"=>"花蓮縣", "V"=>"台東縣", "W"=>"金門縣", "X"=>"澎湖縣",
          "Y"=>"陽明山管理局", "Z"=>"連江縣"
        }
        
        return initial_letter_to_county[id_number_content[0].chr.upcase]
      end
      
      private
      def id_number_content
        self.send(self.class.options[:tw_id_number_column])
      end
    end
  end
end
