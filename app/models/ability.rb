# frozen_string_literal: true

# Clase Ability para definir habilidades de usuario con CanCanCan
class Ability
  include CanCan::Ability

  # Inicializa las habilidades de un usuario
  # @param [User] user usuario para el cual se definen las habilidades

  def initialize(user)
    Rails.logger.debug { "User: #{user.inspect}" }

    # Si el usuario es administrador, puede administrar todo_
    can :manage, :all if user.present? && user.admin?

    # Si el usuario está presente (no es nil), puede realizar ciertas acciones en Product, Review, Message y Solicitud
    if user.present?
      can %i[index leer insertar crear], Product
      can %i[index leer insertar crear], Review
      can %i[leer insertar], Message
      can [:index], Solicitud

      # El usuario puede insertar un producto deseado si el producto no es suyo
      can [:insert_deseado], Product do |product|
        product.user_id != user.id
      end

      # El usuario puede insertar una solicitud si la solicitud no es suya
      can [:insertar], Solicitud do |solicitud|
        solicitud.user_id != user.id
      end

      # El usuario puede eliminar y actualizar un producto si el producto es suyo
      can [:eliminar, :actualizar_producto, :actualizar], Product do |product|
        product.user_id == user.id
      end

      # El usuario puede eliminar y leer una solicitud si la solicitud es suya
      can [:eliminar, :leer], Solicitud do |solicitud|
        solicitud.user_id == user.id
      end

      # El usuario puede eliminar y actualizar una solicitud si el producto de la solicitud es suyo
      can [:eliminar, :actualizar], Solicitud do |solicitud|
        Product.find(solicitud.product_id).user_id == user.id
      end

      # El usuario puede eliminar y actualizar una revisión si la revisión es suya
      can [:eliminar, :actualizar_review, :actualizar], Review do |review|
        review.user_id == user.id
      end

      # El usuario puede eliminar un mensaje si el mensaje es suyo
      can [:eliminar], Message do |message|
        message.user_id == user.id
      end
    end

    # Si el usuario es nil (no está presente), puede realizar ciertas acciones en Product, Review y Message
    return unless user.nil?

    can %i[index leer], Product
    can %i[index leer], Review
    can [:leer], Message
  end
end
