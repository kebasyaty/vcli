module Services::Admin::Routes
  # Get document list.
  post "/admin/document-list" do |env|
    lang_code : String = env.session.string("current_lang")
    auth = Globals::Auth.user_authenticated? env, lang_code
    authenticated? : Bool = auth[:is_authenticated] && auth[:is_admin]
    documents = nil
    page_count : Int32 = 1

    if authenticated?
      model_key = env.params.json["model_key"].as(String)
      model_class = Globals::Extra::Tools.model_class(model_key)
      fields_name = env.params.json["fields_name"].as(Array(JSON::Any)).map(&.to_s)
      field_name_params_list = model_class.meta[:field_name_params_list]
      field_name_params_list.select!(fields_name)
      search_query = env.params.json["search_query"].as(String)
      page_num = env.params.json["page_num"].to_s.to_i32
      limit = env.params.json["limit"].to_s.to_i32
      sort = env.params.json["sort"].as(String)
      direct = env.params.json["direct"].to_s.to_i32
      filter = BSON.new

      if BSON::ObjectId.validate(search_query)
        object_id = BSON::ObjectId.new(search_query)
        tmp_doc : Array(BSON) = [BSON.new({"_id" => object_id})]
        field_name_params_list.each do |field_name, params|
          type_name = params[:type]
          if type_name == "TextField" || type_name == "HashField"
            tmp_doc << BSON.new({field_name => search_query})
          end
        end
        filter["$or"] = tmp_doc
      else
        categories = Hash(String, Hash(String, String | Bool | Array(String))).new
        env.params.json["filters"].as(Hash(String, JSON::Any)).each do |key, value|
          categories[key] = Hash(String, String | Bool | Array(String)).from_json(value.to_s)
        end
        search_query_not_empty? : Bool = !search_query.empty?
        categories_not_empty? : Bool = !categories.empty?

        if search_query_not_empty? || categories_not_empty?
          search_pattern : Regex = /^#{search_query}$/i
          tmp_doc_1 : Array(Hash(String, Regex)) = [] of Hash(String, Regex)
          tmp_doc_2 : Array(BSON) = [] of BSON

          field_name_params_list.each do |field_name, params|
            type_name = params[:type]
            if search_query_not_empty? &&
               Globals::Extra::Tools.text_field_list.includes?(type_name)
              tmp_doc_1 << {field_name => search_pattern}
              next
            end

            if categories_not_empty?
              if category = categories[field_name]?
                negation : Bool = category["negation"].as(Bool)
                val : Globals::Extra::Tools::DataDynamicType? = nil
                if type_name == "ChoiceTextField" || type_name == "ChoiceTextDynField"
                  val = category["value"].as(String)
                  tmp_doc_2 << (negation ? BSON.new({field_name => {"$ne" => val}}) : BSON.new({field_name => val}))
                elsif type_name == "ChoiceTextMultField" || type_name == "ChoiceTextMultDynField"
                  arr = category["value"].as(Array(String))
                  tmp_doc_2 << (negation ? BSON.new({field_name => {"$not" => {"$in" => arr}}}) : BSON.new({field_name => {"$all" => arr}}))
                elsif type_name == "ChoiceI64Field" || type_name == "ChoiceI64DynField"
                  val = category["value"].as(String).to_i64
                  tmp_doc_2 << (negation ? BSON.new({field_name => {"$ne" => val}}) : BSON.new({field_name => val}))
                elsif type_name == "ChoiceI64MultField" || type_name == "ChoiceI64MultDynField"
                  arr = category["value"].as(Array(String)).map(&.to_i64)
                  tmp_doc_2 << (negation ? BSON.new({field_name => {"$not" => {"$in" => arr}}}) : BSON.new({field_name => {"$all" => arr}}))
                elsif type_name == "ChoiceF64Field" || type_name == "ChoiceF64DynField"
                  val = category["value"].as(String).to_f64
                  tmp_doc_2 << (negation ? BSON.new({field_name => {"$ne" => val}}) : BSON.new({field_name => val}))
                elsif type_name == "ChoiceF64MultField" || type_name == "ChoiceF64MultDynField"
                  arr = category["value"].as(Array(String)).map(&.to_f64)
                  tmp_doc_2 << (negation ? BSON.new({field_name => {"$not" => {"$in" => arr}}}) : BSON.new({field_name => {"$all" => arr}}))
                end
              end
            end
          end
          if search_query_not_empty? && categories_not_empty?
            filter["$or"] = tmp_doc_1
            filter["$and"] = tmp_doc_2
          elsif search_query_not_empty?
            filter["$or"] = tmp_doc_1
          else
            filter["$and"] = tmp_doc_2
          end
        end
      end
      projection = {"created_at" => 1, "updated_at" => 1}
      fields_name.each do |name|
        projection[name] = 1
      end
      documents = model_class.admin_document_list(
        filter,
        sort: if sort == "alphabetical_links"
          {fields_name[0] => direct}
        elsif sort == "created"
          {"created_at" => direct}
        elsif sort == "updated"
          {"updated_at": direct}
        else
          nil
        end,
        projection: projection,
        skip: limit * (page_num - 1),
        limit: limit,
        field_name_params_list: field_name_params_list,
      )
      page_count = ((model_class.count_documents(filter) / limit).ceil).to_i32
    end

    result = {
      is_authenticated: authenticated?,
      documents:        documents,
      page_count:       page_count,
    }.to_json
    env.response.content_type = "application/json"
    result
  end
end
