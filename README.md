## Tarea 4

### Logros de la entrega:
[Recuerden especificar quien hizo cada cosa]
* Eduardo Cáceres y Juan Pablo Vera trabajaron juntos en todo lo que habia que hacer, pero Eduardo se concentró principalmente en lograr los test de formularios y Juan Pablo en lograr los tests de navegación y encontrar el error descrito por el enunciado.


### Informacion para el correcto:
Hicimos más tests de lo que debiamos porque leimos mal el enunciado, pero lo dejamos igual.



Para arreglar el error de la primera parte del enunciado se modifico la página leer.html.erb de la carpeta views de products. El input libre que permitía seleccionar cualquier fecha fue cambiado por un select que solamente muestra las fechas disponibles de la reserva. Este es el nuevo código:
<div class="control">
    <select class="input" name="solicitud[reservation_datetime]" required>

        <% @horarios.each do |horario| %>
            <% fecha_hora_str = "#{horario[0]} #{horario[1]}"  %>
            <% fecha_hora = DateTime.strptime(fecha_hora_str, "%d/%m/%Y %H:%M") %>
            <% fecha_hora_termino_str = "#{horario[2]}"  %>
            <% fecha_hora_termino = DateTime.strptime(fecha_hora_termino_str, "%H:%M") %>

            <% # Formato de fecha y hora: dd/mm HH:MM - HH:MM %>
            <option value="<%= "#{fecha_hora}" %>">
                <%= "#{fecha_hora.strftime("%d/%m")} | Horario: #{fecha_hora.strftime("%H:%M")} - #{fecha_hora_termino.strftime("%H:%M")}" %>
            </option>
        <% end %>
    </select>
</div>

La información se sigue mandando en el mismo formato que antes, por lo que nada más tuvo que ser modificado para que la página funcionara. Desde ahora los horarios deben tener formato: dia/mes/año,HH,MM; 
El formato anterior fue agregada al texto a la hora de crear un producto.

### Tests capybara de navegación

Test 1: Este test verifica el proceso de registro de un usuario, navega a través de diferentes funciones disponibles para un usuario normal y luego cierra sesión.

Página inicial: Página de inicio
Página final: Página de inicio

Pasos:

    Redimensiona la ventana del navegador.
    Visita la página de inicio (root_path).
    Hace clic en el enlace "Regístrate" y llena el formulario de registro.
    Hace clic en "Registrarse".
    Hace clic en el botón "Ver canchas y productos" y verifica que los productos están listados.
    Navega a "Mi cuenta" -> "Mi perfil" y verifica el correo electrónico.
    Navega a "Mi cuenta" -> "Solicitudes de compra y reserva" y verifica la página.
    Navega a "Mi cuenta" -> "Lista de deseos" y verifica la página.
    Navega a "Mi cuenta" -> "Mis mensajes" y verifica la página.
    Cierra sesión desde "Mi cuenta" -> "Cerrar Sesión" y verifica que regresa a la página de inicio.

Test 2: Este test verifica el proceso de inicio de sesión, la visualización de un producto, la adición de un producto a la lista de deseos y la navegación al formulario de contacto.

Pasos:

    Redimensiona la ventana del navegador.
    Visita la página de inicio (root_path).
    Hace clic en "Iniciar Sesión" y llena el formulario de inicio de sesión.
    Hace clic en "Iniciar Sesión".
    Hace clic en el botón "Ver canchas y productos" y verifica que los productos están listados.
    Hace clic en el enlace del pie de página para ver el producto.
    Hace clic en "Guardar en deseados" y verifica el mensaje de confirmación.
    Navega a "Mi cuenta" -> "Lista de deseos" y verifica la página.
    Hace clic en "Contacto" y verifica los campos del formulario de contacto.

Página inicial: Página de inicio
Página final: Página de contacto


Test 3: Este test verifica el proceso de inicio de sesión, la visualización de un producto, la adición de un producto al carrito y la navegación a la página de pago.

Pasos:

    Redimensiona la ventana del navegador.
    Visita la página de inicio (root_path).
    Hace clic en "Iniciar Sesión" y llena el formulario de inicio de sesión.
    Hace clic en "Iniciar Sesión".
    Hace clic en el botón "Ver canchas y productos" y verifica que los productos están listados.
    Hace clic en el enlace del pie de página para ver el producto.
    Hace clic en "Reservar ahora" y verifica el mensaje de confirmación.
    Navega a "Mi carrito", hace hover y clic en el botón para ver el carrito, y verifica que el carrito está visible.
    Hace clic en otro botón en el carrito y verifica que no hay productos.

Página inicial: Página de inicio
Página final: Página del carrito de compras (vacío)


Test 4: Este test verifica el proceso de inicio de sesión como administrador, la creación de un producto, la actualización de ese producto y su eliminación.

Pasos:

    Redimensiona la ventana del navegador.
    Visita la página de inicio (root_path).
    Hace clic en "Iniciar Sesión" y llena el formulario de inicio de sesión con credenciales de administrador.
    Hace clic en "Iniciar Sesión".
    Navega a "Productos" y hace clic en el enlace para crear un nuevo producto.
    Llena el formulario de creación de producto y guarda.
    Verifica que el producto ha sido creado.
    Hace clic en el enlace para actualizar el producto.
    Actualiza el stock del producto y guarda.
    Verifica que el producto ha sido actualizado.
    Hace clic en el botón para eliminar el producto y acepta la alerta de confirmación.
    Verifica que el producto ha sido eliminado.

Página inicial: Página de inicio
Página final: Página de listado de productos (sin el producto eliminado)
