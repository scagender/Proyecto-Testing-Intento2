## Tarea X

### Logros de la entrega:
[Recuerden especificar quien hizo cada cosa]
* Eduardo Cáceres y Juan Pablo Vera trabajaron juntos en todo lo que habia que hacer, pero Eduardo se concentró principalmente en lograr los test de integración y juan pablo en lograr los tests unitarios y el CI.
* Se pudo hacer gran parte del coverage de test unitarios y de integración. Se obtuvo alto porcentaje de coverage 97.89%.
* El CI está logrado a medias, todo funciona excepto el chrome headless, por lo que preferimos enfocarnos en otras cosas de la tarea.

### Informacion para el correcto:
Incluir aqui cualquier detalle que pueda ser importante al momento de corregir.

Hubieron muchos tests que a la hora de correrlos, por ejemplo, delete product, que a veces en lugar de mostrar los mensajes correspondientes a delete product se moestraban mensajes que correspondian a actualizar producto. No le pudimos encontrar explicación la verdad, esto afectó nuestro % de coverage, ya que la ruta de actualizar producto ya estaba testeada. Hubo un par de casos así.

No detallo todos, ya que no se si serán relevantes en nuestra nota y realmente sucedían de forma casi aleatoria. A veces los test pasaban a veces no. Como detalle arriba, a veces se metian por otras rutas. Tal vez fue solo a nosotros.

Nada fue modificado.

CI no fue logrado completamente.




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

La información se sigue mandando en el mismo formato que antes, por lo que nada más tuvo que ser modificado para que la página funcionara.