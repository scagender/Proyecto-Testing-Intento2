require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  describe "abilities" do
    subject(:ability) { Ability.new(user) }
    let(:user) { nil }

    context "when user is an admin" do
      let(:user) { User.new(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin') }

      it { should be_able_to(:manage, :all) }
    end

    context "when user is present" do
      let(:user) { User.new(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com') }

      it { should be_able_to(:index, Product) }
      it { should be_able_to(:leer, Product) }
      it { should be_able_to(:insertar, Product) }
      it { should be_able_to(:crear, Product) }

      it { should be_able_to(:index, Review) }
      it { should be_able_to(:leer, Review) }
      it { should be_able_to(:insertar, Review) }
      it { should be_able_to(:crear, Review) }

      it { should be_able_to(:leer, Message) }
      it { should be_able_to(:insertar, Message) }

      it { should be_able_to(:index, Solicitud) }

      it { should_not be_able_to(:insert_deseado, user.products.build) }
      it { should_not be_able_to(:insertar, user.solicituds.build) }

      context "when product belongs to user" do
        let(:product) { Product.new(user: user) }

        it { should be_able_to(:eliminar, product) }
        it { should be_able_to(:actualizar_producto, product) }
        it { should be_able_to(:actualizar, product) }
        #it { should_not be_able_to(:eliminar, user.solicituds.build(product: product)) }
        #it { should_not be_able_to(:actualizar, user.solicituds.build(product: product)) }
      end

      context "when solicitud belongs to user" do
        let(:user) { User.new(name: 'John1', password: 'Nonono123!', email: 'asdf@gmail.com') }
        let(:product) { Product.new(user: user) }
        let(:solicitud) { Solicitud.new(user: user, product: product) }

        #it { should be_able_to(:eliminar, solicitud) }
        it { should be_able_to(:leer, solicitud) }
        #it { should_not be_able_to(:actualizar, solicitud) }
      end

      context "when solicitud's product belongs to user" do
        let(:solicitud) { Solicitud.new }
        let(:product) { Product.new(user: user) }
        
        before { solicitud.product = product }

        #it { should be_able_to(:eliminar, solicitud) }
        #it { should be_able_to(:actualizar, solicitud) }
      end

      context "when review belongs to user" do
        let(:review) { Review.new(user: user) }

        it { should be_able_to(:eliminar, review) }
        it { should be_able_to(:actualizar_review, review) }
        it { should be_able_to(:actualizar, review) }
      end

      context "when message belongs to user" do
        let(:message) { Message.new(user: user) }

        it { should be_able_to(:eliminar, message) }
      end
    end

    context "when user is nil" do
      it { should be_able_to(:index, Product) }
      it { should be_able_to(:leer, Product) }

      it { should be_able_to(:index, Review) }
      it { should be_able_to(:leer, Review) }

      it { should be_able_to(:leer, Message) }

      it { should_not be_able_to(:manage, :all) }
      it { should_not be_able_to(:insertar, Product) }
      it { should_not be_able_to(:crear, Product) }
      it { should_not be_able_to(:insertar, Review) }
      it { should_not be_able_to(:crear, Review) }
      it { should_not be_able_to(:insertar, Message) }
      it { should_not be_able_to(:index, Solicitud) }
    end
  end
end
