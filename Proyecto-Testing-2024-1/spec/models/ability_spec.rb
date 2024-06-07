require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  describe 'abilities' do
    subject(:ability) { Ability.new(user) }
    let(:user) { nil }

    context 'when user is an admin' do
      let(:user) { User.new(name: 'Juan', password: 'Nonono123!', email: 'asdf@gmail.com', role: 'admin') }

      it { should be_able_to(:manage, :all) }
    end

    context 'when user is present' do
      let(:user) { User.new(name: 'Juan', password: 'Nonono123!', email: 'asdf@gmail.com') }
      it { should_not be_able_to(:insert_deseado, user.products.build) }
      it { should_not be_able_to(:insertar, user.solicituds.build) }

      context 'when product belongs to user' do
        let(:product) { Product.create(
          nombre: 'Producto de prueba 2',
          precio: 4000,
          stock: 1,
          user: user,
          categories: 'Cancha'
        ) }
        it { should be_able_to(:eliminar, product) }
        it { should be_able_to(:actualizar_producto, product) }
        it { should be_able_to(:actualizar, product) }
        it { should be_able_to(:eliminar, user.solicituds.build(product: product)) } 
        it { should be_able_to(:actualizar, user.solicituds.build(product: product)) }
      end

      context 'when product does not belong to user' do
        let(:other_product) { Product.create(
          nombre: 'Otro producto',
          precio: 2000,
          stock: 1,
          user: User.create(name: 'Otro usuario', password: 'password123', email: 'otro@example.com', role: 'normal'),
          categories: 'Algo'
        ) }
        it { should_not be_able_to(:eliminar, other_product) }
        it { should_not be_able_to(:actualizar, other_product) }
      end

      context 'when solicitud belongs to user' do
        let(:product) { Product.create(
          nombre: 'Producto de prueba 2',
          precio: 4000,
          stock: 1,
          user: user,
          categories: 'Cancha'
        ) }
        let(:solicitud) { Solicitud.new(user: user, product: product) }

        it { should be_able_to(:leer, solicitud) }
        it { should be_able_to(:eliminar, solicitud) }
      end

      context 'when solicituds product belongs to user' do
        let(:solicitud) { Solicitud.new(product: product) }
        let(:product) { Product.create(
          nombre: 'Producto de prueba 2',
          precio: 4000,
          stock: 1,
          user: user,
          categories: 'Cancha'
        ) }
        before { solicitud.product = product }
        it { should be_able_to(:eliminar, solicitud) } 
        it { should be_able_to(:actualizar, solicitud) }
      end

      context 'when review belongs to user' do
        let(:review) { Review.new(user: user) }

        it { should be_able_to(:eliminar, review) }
        it { should be_able_to(:actualizar_review, review) }
        it { should be_able_to(:actualizar, review) }
      end

      context 'when message belongs to user' do
        let(:message) { Message.new(user: user) }

        it { should be_able_to(:eliminar, message) }
      end
    end

    context 'when user is nil' do
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
      it { should_not be_able_to(:actualizar_producto, Product) }

    end
  end
end