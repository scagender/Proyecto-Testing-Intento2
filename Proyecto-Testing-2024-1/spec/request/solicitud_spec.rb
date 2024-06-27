require 'rails_helper'

RSpec.describe 'Solicitud', type: :request do
  before do
    @user = User.create!(name: 'Juan Gomez', email: 'jgomez@example.com', password: 'Example123!')
    @product = Product.create!(nombre: 'PruebaProducto', precio: 100, stock: 10, user: @user, categories: 'Cancha')
    sign_in @user
  end

  describe 'GET /solicitud/index' do
    it 'retrieves the list of solicitudes and products for the current user' do
      Solicitud.create!(stock: 5, product_id: @product.id, user_id: @user.id, status: 'Pendiente')
      get '/solicitud/index'
      expect(response).to have_http_status(:success)
      expect(assigns(:solicitudes)).to match_array(Solicitud.where(user_id: @user.id))
      expect(assigns(:productos)).to match_array(Product.where(user_id: @user.id))
    end
  end

  describe 'POST /solicitud/insertar' do
    context 'with valid parameters' do
      it 'creates a new Solicitud' do
        valid_attributes = { stock: 5, reservation_datetime: '2024-06-01T10:00:00Z' }

        expect {
          post '/solicitud/insertar', params: { solicitud: valid_attributes, product_id: @product.id }
        }.to change(Solicitud, :count).by(1)

        expect(flash[:notice]).to match(/Solicitud de compra creada correctamente!/)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end

      it 'updates the product stock' do
        valid_attributes = { stock: 5, reservation_datetime: '2024-06-01T10:00:00Z' }

        post '/solicitud/insertar', params: { solicitud: valid_attributes, product_id: @product.id }
        @product.reload
        expect(@product.stock.to_i).to eq(5)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Solicitud with invalid stock' do
        invalid_attributes = { stock: 'w', reservation_datetime: '2024-06-01T10:00:00Z' }

        expect {
          post '/solicitud/insertar', params: { solicitud: invalid_attributes, product_id: @product.id }
        }.to change(Solicitud, :count).by(0)

        expect(flash[:error]).to match(/Hubo un error al guardar la solicitud!/)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end

      it 'does not create a new Solicitud with insufficient product stock' do
        invalid_attributes = { stock: 15, reservation_datetime: '2024-06-01T10:00:00Z' }

        expect {
          post '/solicitud/insertar', params: { solicitud: invalid_attributes, product_id: @product.id }
        }.to change(Solicitud, :count).by(0)

        expect(flash[:error]).to match(/No hay suficiente stock para realizar la solicitud!/)
        expect(response).to redirect_to("/products/leer/#{@product.id}")
      end
    end
  end

  describe 'DELETE /solicitud/eliminar/:id' do
    before do
      @solicitud = Solicitud.create!(stock: 5, product_id: @product.id, user_id: @user.id, status: 'Pendiente')
    end

    it 'deletes the Solicitud' do
      expect {
        delete "/solicitud/eliminar/#{@solicitud.id}"
      }.to change(Solicitud, :count).by(-1)
      expect(response).to redirect_to('/solicitud/index')
    end

    it 'updates the product stock after deleting the Solicitud' do
      delete "/solicitud/eliminar/#{@solicitud.id}"
      @product.reload
      expect(@product.stock.to_i).to eq(15)
    end
  end

  describe 'PATCH /solicitud/actualizar/:id' do
    before do
      @solicitud = Solicitud.create!(stock: 5, product_id: @product.id, user_id: @user.id, status: 'Pendiente')
    end

    it 'updates the Solicitud status' do
      patch "/solicitud/actualizar/#{@solicitud.id}"
      @solicitud.reload
      expect(@solicitud.status).to eq('Aprobada')
      expect(flash[:notice]).to match(/Solicitud aprobada correctamente!/)
      expect(response).to redirect_to('/solicitud/index')
    end
  end
end