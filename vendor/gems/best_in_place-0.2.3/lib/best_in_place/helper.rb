module BestInPlace
  module BestInPlaceHelpers

    def best_in_place(object, field, opts = {})
      opts[:type] ||= :input
      opts[:collection] ||= []
      field = field.to_s
      value = object.send(field).blank? ? "" : object.send(field)
      collection = nil
      if opts[:type] == :select && !opts[:collection].blank?
        v = object.send(field)
        value = Hash[opts[:collection]][!!(v =~ /^[0-9]+$/) ? v.to_i : v]
        collection = opts[:collection].to_json
      end
      if opts[:type] == :checkbox
        fieldValue = !!object.send(field)
        if opts[:collection].blank? || opts[:collection].size != 2
          opts[:collection] = ["No", "Yes"]
        end
        value = fieldValue ? opts[:collection][1] : opts[:collection][0]
        collection = opts[:collection].to_json
      end
      out = "<span class='best_in_place'"
      out << " id='#{BestInPlace::Utils.build_best_in_place_id(object, field)}'"
      out << " data-url='#{opts[:path].blank? ? url_for(object).to_s : url_for(opts[:path])}'"
      out << " data-object='#{object.class.to_s.gsub("::", "_").underscore}'"
      out << " data-collection='#{collection}'" unless collection.blank?
      out << " data-attribute='#{field}'"
      out << " data-activator='#{opts[:activator]}'" unless opts[:activator].blank?
      out << " data-nil='#{opts[:nil].to_s}'" unless opts[:nil].blank?
      out << " data-type='#{opts[:type].to_s}'"
      out << " data-inner-class='#{opts[:inner_class].to_s}'" if opts[:inner_class]
      out << " data-html-attrs='#{opts[:html_attrs].to_json}'" unless opts[:html_attrs].blank?
      if !opts[:sanitize].nil? && !opts[:sanitize]
        out << " data-sanitize='false'>"
        out << sanitize(value.to_s, :tags => %w(b i u s a strong em p h1 h2 h3 h4 h5 ul li ol hr pre span img br), :attributes => %w(id class href))
      else
        out << ">#{sanitize(value.to_s, :tags => nil, :attributes => nil)}"
      end
      out << "</span>"
      raw out
    end

    def best_in_place_if(condition, object, field, opts={})
      if condition
        best_in_place(object, field, opts)
      else
        object.send field
      end
    end
  end
end

