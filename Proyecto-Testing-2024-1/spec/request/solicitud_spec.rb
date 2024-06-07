require 'rails_helper'

RSpec.describe 'Solicitud', type: :request do
    before do
      @user = User.create!(name: 'Juan Gomez', email: 'jgomez@example.com', password: 'Example123!')
      @product = Product.create!(nombre: 'PruebaProducto', precio: 100, stock: 10, user_id: @user.id, categories: 'Cancha')
      sign_in @user
    end
  
    describe 'POST /solicitud/insertar' do
      let(:valid_attributes) { { stock: 5, product_id: @product.id, status: 'Pendiente'} }
      let(:invalid_attributes) { { stock: 'abc', product_id: @product.id, status: 'Pendiente' } }
  
      context 'with valid parameters' do
        it 'creates a new Solicitud' do
          expect {
            post '/solicitud/insertar', params: { solicitud: valid_attributes }
          }.to change(Solicitud, :count).by(1)
          expect(flash[:notice]).to match(/Solicitud de compra creada correctamente!/)
        end
      end
  
      context 'with invalid parameters' do
        it 'does not create a new Solicitud' do
          expect {
            post '/solicitud/insertar', params: { solicitud: invalid_attributes }
          }.to change(Solicitud, :count).by(0)
          expect(flash[:error]).to match(/Hubo un error al guardar la solicitud!/)
        end
      end
    end
  
    describe 'DELETE /solicitud/eliminar/:id' do
      before do
        @solicitud = Solicitud.create!(stock: 5, product_id: @product.id, user_id: @user.id, status: 'Pendiente' )
      end
  
      it 'deletes the Solicitud' do
        expect {
          delete "/solicitud/eliminar/#{@solicitud.id}"
        }.to change(Solicitud, :count).by(-1)
        expect(response).to redirect_to('/solicitud/index')
      end
    end
  
    describe 'PATCH /solicitud/actualizar/:id' do
      before do
        @solicitud = Solicitud.create!(stock: 5, product_id: @product.id, user_id: @user.id, status: 'Pendiente' )
      end
  
      it 'updates the Solicitud status' do
        patch "/solicitud/actualizar/#{@solicitud.id}"
        @solicitud.reload
        expect(@solicitud.status).to eq('Aprobada')
        expect(flash[:notice]).to match(/Solicitud aprobada correctamente!/)
      end
    end
  end