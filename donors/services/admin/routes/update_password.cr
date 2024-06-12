module Vizbor::Services::Admin::Routes
  # Update password
  post "/admin/update-password" do |env|
    authenticated? : Bool = false
    lang_code : String = Vizbor::Settings.default_locale
    msg_err : String = ""
    old_pass : String = env.params.json["old_pass"].as(String)
    new_pass : String = env.params.json["new_pass"].as(String)
    model_key : String = env.params.json["model_key"].as(String)
    doc_hash : String = env.params.json["doc_hash"].as(String)

    # Let's check that the administrator is authenticated
    if !(user = env.session.object?("user")).nil?
      user = user.as(Vizbor::Middleware::Session::UserStorableObject)
      if user.is_admin? && user.is_active?
        authenticated? = true
      else
        msg_err = I18n.t(:auth_failed)
      end
    end

    # Update password
    if authenticated?
      if model_key == Vizbor::Services::Admin::Models::User.full_model_name
        halt env, status_code: 400, response: "Missing document hash." if doc_hash.empty?
        halt env, status_code: 400, response: "Invalid document hash." unless Valid.mongo_id?(doc_hash)
        filter = {"_id": BSON::ObjectId.new(doc_hash)}
        if user = Vizbor::Services::Admin::Models::User.find_one_to_instance(filter)
          begin
            user.update_password(
              old_password: old_pass,
              new_password: new_pass,
            )
          rescue ex : DynFork::Errors::Password::OldPassNotMatch
            msg_err = ex.message.to_s
          end
        else
          halt env, status_code: 400, response: "User is not found." if user.nil?
        end
      else
        halt env, status_code: 400, response: "The model key does not match."
      end
    end

    result : String? = nil
    I18n.with_locale(lang_code) do
      result = {
        is_authenticated: authenticated?,
        service_list:     Vizbor::Compose.get,
        msg_err:          msg_err,
      }.to_json
    end
    env.response.content_type = "application/json"
    result
  end
end
