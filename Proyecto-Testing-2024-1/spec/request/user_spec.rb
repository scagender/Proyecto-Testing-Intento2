require 'rails_helper'

RSpec.describe 'Users', type: :request do
  before do
    @user = User.create!(name: 'Juan Gomez', email: 'jgomez6@example.com', password: 'Ejemplo123!')
    @product1 = Product.create!(nombre: 'Producto 1', precio: 4000, stock: 2, user_id: @user.id, categories: 'Cancha')
    @product2 = Product.create!(nombre: 'Producto 2', precio: 7000, stock: 4, user_id: @user.id, categories: 'Cancha')
    sign_in @user
  end

  describe 'GET /users/show' do
    it 'shows the current user details' do
      get '/users/show'
      expect(response).to have_http_status(:ok)
      expect(assigns(:user)).to eq(@user)
    end
  end

  describe 'GET /users/deseados' do
    it 'shows the current user\'s desired products' do
      @user.deseados << @product1
      @user.deseados << @product2
      get '/users/deseados'
      expect(response).to have_http_status(:ok)
      expect(assigns(:deseados)).to match_array([@product1, @product2])
    end
  end

  describe 'GET /users/mensajes' do
    it 'shows the current user\'s messages' do
      @message1 = Message.create!(body: 'Mensaje uno', product_id: @product1.id, user_id: @user.id)
      @message2 = Message.create!(body: 'Mensaje dos',product_id: @product2.id, user_id: @user.id)

      get '/users/mensajes'
      expect(response).to have_http_status(:ok)
      expect(assigns(:user_messages)).to match_array([@message1, @message2])
    end
  end

  describe 'PATCH /users/actualizar_imagen' do
    context 'with valid image' do
      it 'updates the user image' do
        image = fixture_file_upload('spec/fixtures/files/test.jpg', 'image/jpeg')
        patch '/users/actualizar_imagen', params: { image: image }

        expect(response).to redirect_to('/users/show')
        expect(flash[:notice]).to eq('Imagen actualizada correctamente')
        expect(@user.reload.image).to be_attached
      end
    end

    context 'with invalid image' do
      it 'does not update the user image' do
        image = fixture_file_upload('spec/fixtures/files/test.txt', 'text/plain')
        patch '/users/actualizar_imagen', params: { image: image }
        expect(response).to redirect_to('/users/show')
        expect(flash[:error]).to eq('Hubo un error al actualizar la imagen. Verifique que la imagen es de formato jpg, jpeg, png, gif o webp')
        expect(@user.reload.image).not_to be_attached
      end
    end
  end

  describe 'DELETE /users/eliminar_deseado' do
    it 'removes a product from the user\'s desired list' do
      @product = Product.create!(nombre: 'Producto', precio: 7000, stock: 4, user_id: @user.id, categories: 'Cancha')
      @user.deseados << @product

      delete '/users/eliminar_deseado/deseado_id', params: { deseado_id: @product.id }
      expect(response).to redirect_to('/users/deseados')
      expect(flash[:notice]).to eq('Producto quitado de la lista de deseados')
      expect(@user.reload.deseados).not_to include(@product)
    end

    it 'shows an error if unable to remove the product' do
      allow_any_instance_of(User).to receive(:save).and_return(false)
      @product = Product.create!(nombre: 'Producto 1', precio: 400, stock: 1, user_id: @user.id, categories: 'Cancha')
      @user.deseados << @product

      delete '/users/eliminar_deseado/deseado_id', params: { deseado_id: @product.id }
      expect(response).to redirect_to('/users/deseados')
      expect(flash[:error]).to eq('Hubo un error al quitar el producto de la lista de deseados')
      expect(@user.reload.deseados).to include(@product)
    end
  end
end
