module Spree
  module Products
    class FiltersPresenter
      def initialize(current_store, current_currency, params)
        @products_for_filters = find_products_for_filters(current_store, current_currency, params)
      end

      def to_h
        option_values = Spree::OptionValues::FindAvailable.new(products_scope: products_for_filters).execute
        product_properties = Spree::ProductProperties::FindAvailable.new(products_scope: products_for_filters).execute

        {
          option_types: Spree::Products::OptionTypeFiltersPresenter.new(option_values).to_a,
          product_properties: Spree::Products::PropertyFiltersPresenter.new(product_properties).to_a
        }
      end

      private

      attr_reader :products_for_filters

      def find_products_for_filters(current_store, current_currency, params)
        current_taxon = find_current_taxon(current_store, params)
        current_store.products.for_filters(current_currency, taxon: current_taxon)
      end

      def find_current_taxon(current_store, params)
        taxons_param = params.dig(:filter, :taxons)
        return nil if taxons_param.nil? || taxons_param.to_s.blank?

        @current_taxon ||= current_store.taxons.find_by(id: taxons_param.to_i)
      end
    end
  end
end