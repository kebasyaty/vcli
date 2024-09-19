# Additional methods for class model.
module Globals::Extra::ClassMethods
  extend self

  IMG_URLS = ["url_xs", "url_sm", "url_md", "url_lg", "url"]

  # Get document list.
  def admin_document_list(
    filter = BSON.new,
    *,
    sort = nil,
    projection = nil,
    hint : (String | Hash | NamedTuple)? = nil,
    skip : Int32? = nil,
    limit : Int32? = nil,
    batch_size : Int32? = nil,
    single_batch : Bool? = nil,
    comment : String? = nil,
    max_time_ms : Int64? = nil,
    read_concern : Mongo::ReadConcern? = nil,
    max = nil,
    min = nil,
    return_key : Bool? = nil,
    show_record_id : Bool? = nil,
    tailable : Bool? = nil,
    oplog_replay : Bool? = nil,
    no_cursor_timeout : Bool? = nil,
    await_data : Bool? = nil,
    allow_partial_results : Bool? = nil,
    allow_disk_use : Bool? = nil,
    collation : Mongo::Collation? = nil,
    read_preference : Mongo::ReadPreference? = nil,
    session : Mongo::Session::ClientSession? = nil,
    field_name_params_list : Hash(String, NamedTuple(type: String, group: UInt8)),
  ) : Array(Hash(String, DynFork::Globals::FieldValueTypes))
    #
    unless @@meta.not_nil![:migrat_model?]
      raise DynFork::Errors::Panic.new(
        "Model : `#{@@full_model_name}` > Param: `migrat_model?` => " +
        "This Model is not migrated to the database!"
      )
    end
    # Get collection for current model.
    collection : Mongo::Collection = DynFork::Globals.mongo_database[
      @@meta.not_nil![:collection_name]]
    #
    hash_list = Array(Hash(String, DynFork::Globals::FieldValueTypes)).new
    cursor : Mongo::Cursor = collection.find(
      filter: filter,
      sort: sort,
      projection: projection,
      hint: hint,
      skip: skip,
      limit: limit || @@meta.not_nil![:db_query_docs_limit],
      batch_size: batch_size,
      single_batch: single_batch,
      comment: comment,
      max_time_ms: max_time_ms,
      read_concern: read_concern,
      max: max,
      min: min,
      return_key: return_key,
      show_record_id: show_record_id,
      tailable: tailable,
      oplog_replay: oplog_replay,
      no_cursor_timeout: no_cursor_timeout,
      await_data: await_data,
      allow_partial_results: allow_partial_results,
      allow_disk_use: allow_disk_use,
      collation: collation,
      read_preference: read_preference,
      session: session,
    )
    #
    field_name_params_list_ptr = pointerof(field_name_params_list)
    cursor.each { |document|
      hash_list << self.admin_document_to_hash(pointerof(document), field_name_params_list_ptr)
    }
    #
    hash_list
  end

  # Get clean data from a document, as a Hash object.
  def admin_document_to_hash(
    doc_ptr : Pointer(BSON),
    field_name_params_list_ptr : Pointer(Hash(String, NamedTuple(type: String, group: UInt8)))
  ) : Hash(String, DynFork::Globals::FieldValueTypes)
    #
    doc_hash = doc_ptr.value.to_h
    result = Hash(String, DynFork::Globals::FieldValueTypes).new
    result["hash"] = doc_hash["_id"].as(BSON::ObjectId).to_s
    result["created_at"] = doc_hash["created_at"].as(Time).to_s("%FT%H:%M:%S")
    result["updated_at"] = doc_hash["updated_at"].as(Time).to_s("%FT%H:%M:%S")
    field_type : String = ""
    #
    field_name_params_list_ptr.value.each do |field_name, field_params|
      if !(value = doc_hash[field_name]).nil?
        field_type = field_params[:type]
        case field_params[:group]
        when 1
          # ColorField | EmailField | PasswordField | PhoneField
          # | TextField | HashField | URLField | IPField
          if field_type != "PasswordField"
            tmp_val = value.as(String)
            if field_type == "ColorField"
              tmp_val = %Q(<div class="show-color" style="background-color:#{tmp_val};"></div>)
            end
            result[field_name] = tmp_val
          else
            result[field_name] = nil
          end
        when 2
          # DateField | DateTimeField
          if field_type.includes?("Time")
            result[field_name] = value.as(Time).to_s("%FT%H:%M:%S")
          else
            result[field_name] = value.as(Time).to_s("%F")
          end
        when 3
          # ChoiceTextField | ChoiceI64Field
          # | ChoiceF64Field | ChoiceTextMultField
          # | ChoiceI64MultField | ChoiceF64MultField
          # | ChoiceTextMultField | ChoiceI64MultField
          # | ChoiceF64MultField | ChoiceTextMultDynField
          # | ChoiceI64MultDynField | ChoiceF64MultDynField
          # ChoiceTextField | ChoiceI64Field
          # | ChoiceF64Field | ChoiceTextMultField
          # | ChoiceI64MultField | ChoiceF64MultField
          # | ChoiceTextMultField | ChoiceI64MultField
          # | ChoiceF64MultField | ChoiceTextMultDynField
          # | ChoiceI64MultDynField | ChoiceF64MultDynField
          if field_type.includes?("Text")
            if field_type.includes?("Mult")
              tmp_arr = value.as(Array(BSON::RecursiveValue)).map(&.as(String))
              tmp_arr.map! { |item|
                if DynFork::Globals.regex[:color_code].matches?(item)
                  %Q(<div class="sm-show-color" style="background-color:#{item};"></div>)
                else
                  item
                end
              }
              result[field_name] = tmp_arr.join(%Q(<span class="green--text"> | </span>))
            else
              result[field_name] = value.as(String)
            end
          elsif field_type.includes?("I64")
            if field_type.includes?("Mult")
              tmp_arr = value.as(Array(BSON::RecursiveValue)).map(&.as(Int64))
              result[field_name] = tmp_arr.join(%Q(<span class="green--text"> | </span>))
            else
              result[field_name] = value.as(Int64)
            end
          elsif field_type.includes?("F64")
            if field_type.includes?("Mult")
              tmp_arr = value.as(Array(BSON::RecursiveValue)).map(&.as(Float64))
              result[field_name] = tmp_arr.join(%Q(<span class="green--text"> | </span>))
            else
              result[field_name] = value.as(Float64)
            end
          end
        when 4
          # FileField
        when 5
          # ImageField
          bson = BSON.new
          value.as(Hash(String, BSON::RecursiveValue)).each { |key, val| bson[key] = val }
          IMG_URLS.each do |key|
            if url = bson[key]?
              result[field_name] =
                %Q(<img class="rounded-lg mt-1" src="#{url.not_nil!.as(String)}" height="40" alt="Image">)
              break
            end
          end
        when 6
          # I64Field
          result[field_name] = value.as(Int64)
        when 7
          # F64Field
          result[field_name] = value.as(Float64)
        when 8
          # BoolField
          val = if value.as(Bool)
                  # {icon_name, color_name}
                  {"checkbox-marked-outline", "orange"}
                else
                  {"checkbox-blank-outline", "lime"}
                end
          result[field_name] = %Q(<span class="mdi mdi-24px mdi-#{val[0]} #{val[1]}--text text--darken-1"></span>)
        when 9
          # SlugField
          result[field_name] = value.as(String)
        else
          raise DynFork::Errors::Model::InvalidGroupNumber
            .new(@@full_model_name, field_name)
        end
      else
        result[field_name] = nil
      end
    end
    #
    result
  end
end
