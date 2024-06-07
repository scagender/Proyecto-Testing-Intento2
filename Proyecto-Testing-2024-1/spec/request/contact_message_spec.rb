require 'rails_helper'

RSpec.describe 'ContactMessages', type: :request do
  before do
    @admin = User.create!(name: 'Usuario admin', password: 'Ejemplo123!', email: 'admin1@gmail.com', role: 'admin')
    @user = User.create!(name: 'Usuario regular', password: 'Ejemplo123!', email: 'user1@gmail.com', role: 'user')
    sign_in @admin
  end

  describe 'POST /contacto/crear' do
    let(:valid_attributes) { { name: 'Juan Gomez', mail: 'jgomez@example.com', title: 'Test', body: 'Test message' } }
    let(:invalid_attributes) { { name: '', mail: '', title: '', body: '' } }

    context 'with valid parameters' do
      it 'creates a new ContactMessage' do
        expect {
          post '/contacto/crear', params: { contact: valid_attributes }
        }.to change(ContactMessage, :count).by(1)
        expect(flash[:notice]).to match(/Mensaje de contacto enviado correctamente/)
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new ContactMessage' do
        expect {
          post '/contacto/crear', params: { contact: invalid_attributes }
        }.to change(ContactMessage, :count).by(0)
        expect(flash[:alert]).to match(/Error al enviar el mensaje de contacto/)
      end
    end
  end

  describe 'DELETE contacto/eliminar/:id' do
    before do
      @contact_message = ContactMessage.create!(name: 'Juan Gomez', mail: 'jgomez2@example.com', title: 'Test', body: 'Test message')
    end

    context 'as an admin' do
      it 'deletes the contact message' do
        expect {
          delete "/contacto/eliminar/#{@contact_message.id}"
        }.to change(ContactMessage, :count).by(-1)
        expect(flash[:notice]).to match(/Mensaje de contacto eliminado correctamente/)
      end
    end

    context 'as a non-admin user' do
      before do
        sign_out @admin
        sign_in @user
      end

      it 'does not allow deletion of the contact message' do
        expect {
          delete "/contacto/eliminar/#{@contact_message.id}"
        }.to change(ContactMessage, :count).by(0)
        expect(flash[:alert]).to match(/Debes ser un administrador para eliminar un mensaje de contacto./)
      end
    end
  end

  describe 'DELETE /contacto/limpiar' do
    before do
      @contact_message1 = ContactMessage.create!(name: 'Juan Gomez', mail: 'jgomez3@example.com', title: 'Test', body: 'Test message')
      @contact_message2 = ContactMessage.create!(name: 'Alejandra Gomez', mail: 'agomez@example.com', title: 'Test', body: 'Test message')
    end

    context 'as an admin' do
      it 'deletes all contact messages' do
        expect {
          delete '/contacto/limpiar'
        }.to change(ContactMessage, :count).by(-2)
        expect(flash[:notice]).to match(/Mensajes de contacto eliminados correctamente/)
      end
    end

    context 'as a non-admin user' do
      before do
        sign_out @admin
        sign_in @user
      end

      it 'does not allow deletion of all contact messages' do
        expect {
          delete '/contacto/limpiar'
        }.to change(ContactMessage, :count).by(0)
        expect(flash[:alert]).to match(/Debes ser un administrador para eliminar los mensajes de contacto./)
      end
    end
  end
end