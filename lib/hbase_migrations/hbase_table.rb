class HbaseTable
  
  def initialize(configuration, tableName)
    @table = Java::OrgApacheHadoopHbaseClient::HTable.new(configuration, tableName)
  end
  
  def all_columns
     htd = @table.getTableDescriptor()
     result = []
     for f in htd.getFamilies()
       n = f.getNameAsString()
       n << ':'
       result << n
     end
     result
  end
  
  def count(interval=1000)
    columns = all_columns.to_java(java.lang.String)
    scanner = @table.getScanner(columns)
      
    row_count = 0
    scanner.each do |result|
      row_count += 1
      puts "Current count: #{row_count}, row: #{String.from_java_bytes(result.getRow())}" if row_count % interval == 0
    end
    row_count
  end
  
  def get(row)
     result = @table.getRow(row.to_java_bytes)
  
     answer ={}
     
     if result.instance_of? Java::OrgApacheHadoopHbaseIo::RowResult
       row_id = String.from_java_bytes result.getRow()
       row_value = {}
       
       if result
         for k, v in result
           column = String.from_java_bytes k
           row_value[column] = String.from_java_bytes result.get(k).value
         end
         answer[row_id] = row_value
       end
     end
     
     return answer
   end
   
   def put(row, column, value)
     bu = Java::OrgApacheHadoopHbaseIo::BatchUpdate.new(row)
     bu.put(column, value.to_java_bytes)
     @table.commit(bu)
   end
   
   def table_descriptor
    @table.getTableDescriptor()
   end

end