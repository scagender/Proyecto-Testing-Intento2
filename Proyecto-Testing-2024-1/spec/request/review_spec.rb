require 'rails_helper'

RSpec.describe 'Reviews', type: :request do
  before do
    @user = User.create!(name: 'Juan Gomez', email: 'jgomez3@example.com', password: 'Example123!')
    @product = Product.create!(nombre: 'PruebaProducto', precio: 100, stock: 10, user_id: @user.id, categories: 'Cancha')
    sign_in @user
  end

  describe 'POST review/insertar' do
    let(:valid_attributes) { { tittle: 'Buen producto', description: 'Funciona bien!', calification: 5, product_id: @product.id } }
    let(:invalid_attributes) { { tittle: '', description: '', calification: '', product_id: @product.id } }
    context 'with valid parameters' do
      it 'creates a new Review' do
        expect {
          post '/review/insertar', params: valid_attributes
        }.to change(Review, :count).by(1)
        expect(flash[:notice]).to match(/Review creado Correctamente !/)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Review' do
        expect {
          post '/review/insertar', params: invalid_attributes
        }.to change(Review, :count).by(0)
        expect(flash[:error]).to match(/Hubo un error al guardar la reseña; debe completar todos los campos solicitados./)
      end
    end
  end

  describe 'PATCH /review/actualizar/:id' do
    before do
      @review = Review.create!(tittle: 'Buen producto', description: 'Funciona bien!', calification: 5, product_id: @product.id, user_id: @user.id)
    end

    context 'with valid parameters' do
      it 'updates the Review' do
        patch "/review/actualizar/#{@review.id}", params: { tittle: "Updated tittle" }
        @review.reload
        expect(@review.tittle).to eq('Updated tittle')
      end
    end

    context 'with invalid parameters' do
      it 'does not update the Review' do
        patch "/review/actualizar/#{@review.id}", params: { tittle: '' }
        @review.reload
        expect(@review.tittle).to eq('Buen producto') 
        expect(flash[:error]).to match(/Hubo un error al editar la reseña. Complete todos los campos solicitados!/)
      end
    end
  end

  describe 'DELETE /review/eliminar/:id' do
    before do
      @review = Review.create!(tittle: 'Buen producto', description: 'Funciona bien!', calification: 5, product_id: @product.id, user_id: @user.id)
    end

    it 'deletes the Review' do
      expect {
        delete "/review/eliminar/#{@review.id}"
      }.to change(Review, :count).by(-1)
      expect(response).to redirect_to("/products/leer/#{@product.id}")
    end
  end
end