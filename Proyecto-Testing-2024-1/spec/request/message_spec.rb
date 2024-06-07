require 'rails_helper'

RSpec.describe 'Messages', type: :request do
  before do
    @admin = User.create!(name: 'Usuario admin', password: 'ejemplo123', email: 'admin4@gmail.com', role: 'admin')
    @user = User.create!(name: 'Usuario regular', password: 'ejemplo123', email: 'user2@gmail.com', role: 'user')
    @product = Product.create!(nombre: 'Producto 1', precio: 4000, stock: 1, user_id: @admin.id, categories: 'Cancha')
    sign_in @admin
  end

  describe 'POST /messages/insertar' do
    let(:valid_attributes) { { body: 'Nuevo Mensaje' } }
    let(:invalid_attributes) { { body: '' } }

    context 'with valid parameters' do
      it 'creates a new Message' do
        expect {
          post '/message/insertar', params: { message: valid_attributes, product_id: @product.id }
        }.to change(Message, :count).by(1)
        expect(flash[:notice]).to match(/Pregunta creada correctamente!/)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Message' do
        expect {
          post '/message/insertar', params: { message: invalid_attributes, product_id: @product.id }
        }.to change(Message, :count).by(0)
        expect(flash[:error]).to match(/Hubo un error al guardar la pregunta./)
      end
    end

    context 'as a non-admin user' do
      before do
        sign_out @admin
        sign_in @user
      end

      it 'creates a new Message' do
        expect {
          post '/message/insertar', params: { message: valid_attributes, product_id: @product.id }
        }.to change(Message, :count).by(1)
        expect(flash[:notice]).to match(/Pregunta creada correctamente!/)
      end
    end
  end

  describe 'DELETE /message/eliminar' do
    before do
      @message = Message.create!(body: 'Mensaje para eliminar', product_id: @product.id, user_id: @admin.id)
    end

    context 'as an admin' do
      it 'deletes the message' do
        expect {
          delete '/message/eliminar', params: { message_id: @message.id, product_id: @product.id }
        }.to change(Message, :count).by(-1)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end

    context 'as a non-admin user' do
      before do
        sign_out @admin
        sign_in @user
      end

      it 'does not allow deletion of the message' do
        expect {
          delete '/message/eliminar', params: { message_id: @message.id, product_id: @product.id }
        }.to change(Message, :count).by(-1)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end
  end
end
