require_relative './sdk'
require 'digest'

def get_args_or_exit!()
  # really stupid arg parsing
  if ARGV.length < 2 
    puts "usage: bundle exec ruby export.rb <poi or ssf or both> <query_id: id or quid> [<apply formatting: true or false>] [<dev mode: true or false>]"
    exit(1)
  else
    unless ["poi", "ssf", "both", "test"].include?(ARGV[0])
      puts "first argument must be poi or ssf or both"
      exit(1)
    end

    [ARGV[0], ARGV[1], ARGV[2] || true, ARGV[3] || 'false']
  end
end

def find_query_by_id(sdk, qid)
  begin
    sdk.query(qid)
  rescue => e
    # todo debug?

    nil    
  end 
end 

def find_query_by_qid(sdk, qid)
  begin
    sdk.query_for_slug(qid)
  rescue => e
    # todo debug?

    nil    
  end 
end 

def print_query_details(query)
  puts "slug / id #{query.client_id} / #{query.id}"
  puts "model: #{query.model}"
  puts "view: #{query.view}"
  puts "field: #{query.fields}"
  puts "filters: #{query.filters.to_h}"
  puts "pivots: #{query.pivots}"
  puts "sorts: #{query.sorts}"
  puts "limit: #{query.limit}"
  puts "column_limit: #{query.column_limit}"
  puts "totals: #{query.total}"
  puts "row_totals: #{query.row_total}"
  puts "subtotals: #{query.subtotals}"
  puts "fill_fields: #{query.fill_fields}"
  puts "share_url: #{query.expanded_share_url}" 
end


type, qid, apply_formatting, dev_mode = get_args_or_exit!()
sdk = SDK.create_authenticated_sdk
sdk.alive
current_user = sdk.me

puts "current user (#{current_user.id}) #{current_user.display_name}"
if dev_mode == "true"
  puts "entering dev mode"
  sdk.update_session(workspace_id: 'dev')
end

query = find_query_by_id(sdk, qid) || find_query_by_qid(sdk, qid)
unless query
  puts "could not find query with id or qid: #{qid}"
  exit(1)
end 

print_query_details(query)
old_data = ""
if type == "poi" || type == "both" || type == "test"
  sdk.run_query(query.id, "csv", {cache: false, apply_formatting: apply_formatting, fast_value_formatter: true}) do |out_chunk|
    old_data << out_chunk
  end
  if type != "test"
    puts "\n------ new formatter data below ---------"
    puts old_data
    puts "------ new formatter data above ---------\n"
  end
end

new_data = ""
if type == "ssf" || type == "both" || type == "test"
  sdk.run_query(query.id, "csv", {cache: false, apply_formatting: apply_formatting}) do |out_chunk|
    new_data << out_chunk
  end
  if type != "test"
    puts "\n------ old formatter data below ---------"
    puts new_data
    puts "------ old formatter data above ---------\n"
  end
end

if type == "both" || type == "test"
  new_digest = Digest::MD5.hexdigest(new_data)
  old_digest = Digest::MD5.hexdigest(old_data)

  if new_digest == old_digest
    puts "data contents are identical md5: #{new_digest}"
    exit(1)
  else
    puts "data digests are different new: #{new_digest} old: #{old_digest}"
  end
  
  size_same = new_data.length == old_data.length
  if size_same
    puts "both outputs have the same size: #{new_data.length}"
  else
    puts "outputs have different sizes new: #{new_data.length} old: #{old_data.length}"
  end
  
  new_rows = new_data.split("\n")
  old_rows = old_data.split("\n")

  if new_rows.length == old_rows.length
    puts "both outputs have the same number of rows: #{new_rows.length}"
  else
    puts "outputs have different numbers of rows new: #{new_rows.length} old: #{old_rows.length}"
  end

  new_rows_first = new_rows.length >= old_rows.length
  first_rows = new_rows_first ? new_rows : old_rows
  second_rows = new_rows_first ? old_rows : new_rows

  first_row_desc = new_rows_first ? "new" : "old"
  second_row_desc = new_rows_first ? "old" : "new"
  
  first_rows.each_with_index do |first_row, index|
    second_row = second_rows[index] rescue nil
    
    if second_row.nil?
      puts "no matching #{second_row_desc} row for #{first_row_desc} index #{index}"
      exit(1)
    end
    
    next if first_row == second_row

    puts "#{first_row_desc} row"
    puts first_row

    puts "#{second_row_desc} row"
    puts second_row
    
    break
  end
end

puts "check for failures here: https://master.dev.looker.com/admin/queries"
