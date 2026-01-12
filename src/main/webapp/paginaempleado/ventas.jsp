<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.sql.*, com.ferreteria.datos.Conexion" %>

<%
Object carritoObj = session.getAttribute("carrito");
Map<String, Map<String,Object>> carrito;

if (carritoObj instanceof Map) carrito = (Map<String, Map<String,Object>>) carritoObj;
else { carrito = new LinkedHashMap<>(); session.setAttribute("carrito", carrito); }

String accion = request.getParameter("accion");

if ("agregar".equals(accion)) {
    try{
        int id = Integer.parseInt(request.getParameter("id_producto"));
        int cant = Integer.parseInt(request.getParameter("cantidad"));
        double precio = Double.parseDouble(request.getParameter("precio"));

        String key = String.valueOf(id);

        if(carrito.containsKey(key)){
            int old = (int)carrito.get(key).get("cantidad");
            carrito.get(key).put("cantidad", old + cant);
        } else {
            Map<String,Object> item=new HashMap<>();
            item.put("id",id); item.put("cantidad",cant); item.put("precio",precio);
            carrito.put(key,item);
        }
    }catch(Exception e){ out.print("<script>alert('Error: "+e+"');</script>"); }

} else if ("eliminar".equals(accion)) carrito.remove(request.getParameter("id"));
else if ("eliminarUltimo".equals(accion)) {
    if(!carrito.isEmpty()){ List<String> k=new ArrayList<>(carrito.keySet()); carrito.remove(k.get(k.size()-1)); }
}
else if ("editar".equals(accion)){
    try{
        String id=request.getParameter("id_edit");
        int c=Integer.parseInt(request.getParameter("cantidad_edit"));
        if(carrito.containsKey(id)) carrito.get(id).put("cantidad", c);
    }catch(Exception e){}
}
else if ("limpiar".equals(accion)) carrito.clear();

else if ("finalizar".equals(accion)){
    if(!carrito.isEmpty()){
        int idUsuario=(int)session.getAttribute("id_usuario");
        int idVenta=0;
        try(Conexion cn=new Conexion()){
            PreparedStatement ps=cn.getConexion().prepareStatement(
                "INSERT INTO tb_venta(id_usuario,total) VALUES(?,0) RETURNING id_venta");
            ps.setInt(1,idUsuario);
            ResultSet rs=ps.executeQuery();
            if(rs.next()) idVenta=rs.getInt(1);

            PreparedStatement ps2=cn.getConexion().prepareStatement(
                "INSERT INTO tb_venta_detalle(id_venta,id_producto,cantidad,precio_unitario) VALUES(?,?,?,?)");

            for(String key:carrito.keySet()){
                Map<String,Object> item=carrito.get(key);
                ps2.setInt(1,idVenta);
                ps2.setInt(2,(int)item.get("id"));
                ps2.setInt(3,(int)item.get("cantidad"));
                ps2.setDouble(4,(double)item.get("precio"));
                ps2.executeUpdate();
            }

            carrito.clear();
            out.print("<script>playOk(); alert('Venta registrada');</script>");

        }catch(Exception e){ out.print("<script>playError(); alert('ERROR: "+e+"');</script>"); }
    }
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>POS</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="general/general.css">

<style>
.atajos{position:fixed;right:20px;top:120px;width:260px;}
.stockBajo{color:red;font-weight:bold;}
.filaAnimada{animation:flash .4s;}
@keyframes flash{0%{background:#baffba;}100%{background:white;}}
</style>

<!-- SONIDOS -->
<audio id="snd-ok"><source src="https://actions.google.com/sounds/v1/cartoon/pop.ogg"></audio>
<audio id="snd-error"><source src="https://actions.google.com/sounds/v1/cartoon/wood_plank_flicks.ogg"></audio>
<audio id="snd-alert"><source src="https://actions.google.com/sounds/v1/cartoon/clang_and_wobble.ogg"></audio>

<script>
function playOk(){ snd_ok.play(); }
function playError(){ snd_error.play(); }
function playAlert(){ snd_alert.play(); }

let stockMap = {};
function registrarStock(id,st){ stockMap[id]=st; }
function bajarStock(id,c){
    if(stockMap[id]!=null) stockMap[id]-=c;
    let opt=document.querySelector("#producto option[value='"+id+"']");
    if(opt){
        let base=opt.textContent.split("(Stock")[0];
        opt.textContent = base+"(Stock: "+stockMap[id]+")";
        if(stockMap[id]<=0) opt.classList.add("stockBajo");
    }
}

function calcularTotal(){
    total.value = (parseFloat(cantidad.value||1)*parseFloat(precio.value||0)).toFixed(2);
}

function buscarPorCodigo(c){
    if(c.length<2) return;
    let sel=producto;
    for(let o of sel.options){
        if(o.dataset.codigo===c){
            sel.value=o.value;
            precio.value=o.dataset.precio;
            cantidad.value=1;
            codigo.value=o.dataset.codigo;
            calcularTotal(); playOk();
            return;
        }
    } playError();
}

function cargarPrecioDesdeSelect(){
    let o=producto.options[producto.selectedIndex];
    if(!o||!o.dataset) return;
    precio.value=o.dataset.precio;
    cantidad.value=1;
    codigo.value=o.dataset.codigo;
    calcularTotal();
}

/* VALIDACIÓN DE STOCK REAL */
function validarStockAntesDeAgregar(){
    let id=producto.value, cantNueva=parseInt(cantidad.value);
    if(!id||cantNueva<=0){playError();alert("Producto inválido");return false;}

    let cantCarrito=0;
    document.querySelectorAll(".filaCarrito").forEach(f=>{
        if(f.dataset.id==id) cantCarrito=parseInt(f.dataset.cant);
    });

    let stock=stockMap[id];
    if(cantCarrito+cantNueva>stock){
        playError();
        alert("Stock insuficiente. Ya tiene "+cantCarrito);
        return false;
    }
    return true;
}

/* ATAJOS */
document.addEventListener("keydown",e=>{
    if(!e.ctrlKey)return;
    let k=e.key.toLowerCase();
    if(k==="a"){e.preventDefault();btnAgregar.click();}
    if(k==="f"){e.preventDefault();btnFinalizar.click();}
    if(k==="l"){e.preventDefault();location.href="ventas.jsp?accion=limpiar";}
    if(k==="c"){e.preventDefault();codigo.focus();}
    if(k==="d"){e.preventDefault();location.href="ventas.jsp?accion=eliminarUltimo";}
    if(k==="e"){e.preventDefault();editarUltimo();}
    if(k==="b"){e.preventDefault();new bootstrap.Modal(modalBuscar).show();buscarInput.focus();}
    if(k==="u"){e.preventDefault();new bootstrap.Modal(modalUltimas).show();}
});

/* EDITAR ÚLTIMO */
function editarUltimo(){
    let filas=document.querySelectorAll(".filaCarrito");
    if(filas.length===0){playAlert();return;}
    let f=filas[filas.length-1];
    id_edit.value=f.dataset.id;
    cantidad_edit.value=f.dataset.cant;
    new bootstrap.Modal(modalEditar).show();
}

/* BUSCADOR DEL SELECT */
function filtrarSelectProducto(){
    let texto = buscarProducto.value.toLowerCase();
    let opciones = producto.options;
    for(let i=0;i<opciones.length;i++){
        let txt=opciones[i].textContent.toLowerCase();
        opciones[i].style.display = txt.includes(texto)? "":"none";
    }
    for(let i=0;i<opciones.length;i++){
        if(opciones[i].style.display!=="none"){
            producto.value=opciones[i].value;
            cargarPrecioDesdeSelect();
            break;
        }
    }
}

/* BUSCADOR MODAL */
function filtrarProductos(){
    let txt=buscarInput.value.toLowerCase();
    document.querySelectorAll("#tablaBuscar tbody tr").forEach(f=>{
        f.style.display=f.innerText.toLowerCase().includes(txt)?"":"none";
    });
}

function seleccionarBusqueda(id,precioU){
    producto.value=id;
    precio.value=precioU;
    cantidad.value=1;
    let opt=document.querySelector("#producto option[value='"+id+"']");
    if(opt) codigo.value=opt.dataset.codigo;
    calcularTotal();
    playOk();
    bootstrap.Modal.getInstance(modalBuscar).hide();
}
</script>
</head>

<body class="bodygeneral">
<jsp:include page="../head&foot/menuu.jsp" />

<div class="container py-4">
<h2 class="text-primary mb-4">Punto de Venta</h2>

<!-- ================= FORMULARIO ================= -->
<div class="card shadow mb-4">
<div class="card-body">
<form method="post" onsubmit="return validarStockAntesDeAgregar()">
<input type="hidden" name="accion" value="agregar">

<div class="row g-3">

<div class="col-md-4">
<label>Código</label>
<input type="text" id="codigo" name="codigo" class="form-control" onkeyup="buscarPorCodigo(this.value)">
</div>

<div class="col-md-4">
<label>Producto</label>

<!-- BUSCADOR EN SELECT -->
<input type="text" id="buscarProducto" class="form-control mb-1" placeholder="Buscar..." onkeyup="filtrarSelectProducto()">

<select id="producto" name="id_producto" class="form-select" size="6" onchange="cargarPrecioDesdeSelect()" required>
<option value="">Seleccione...</option>

<%
try(Conexion cn=new Conexion()){
    ResultSet rs=cn.Consulta("SELECT * FROM tb_producto WHERE activo=true ORDER BY nombre");
    while(rs.next()){
%>
<option value="<%=rs.getInt("id_producto")%>"
        data-precio="<%=rs.getDouble("precio_venta")%>"
        data-codigo="<%=rs.getString("codigo_barra")%>">
    <%=rs.getString("nombre")%> (Stock: <%=rs.getInt("cantidad")%>)
</option>

<script> registrarStock(<%=rs.getInt("id_producto")%>, <%=rs.getInt("cantidad")%>); </script>
<%
    }
}
%>

</select>
</div>

<div class="col-md-2">
<label>Precio</label>
<input type="number" id="precio" name="precio" class="form-control" readonly>
</div>

<div class="col-md-2">
<label>Cantidad</label>
<input type="number" id="cantidad" name="cantidad" class="form-control" value="1" min="1" onkeyup="calcularTotal()">
</div>

<div class="col-md-2">
<label>Total</label>
<input type="text" id="total" class="form-control" readonly>
</div>

<div class="col-12 text-end">
<button type="submit" id="btnAgregar" class="btn btn-success">Registrar (Ctrl+A)</button>
</div>

</div>
</form>
</div>
</div>

<!-- ================= CARRITO ================= -->
<div class="card shadow mb-4">
<div class="card-header bg-dark text-white">Carrito</div>
<div class="card-body">

<table class="table table-bordered text-center">
<thead><tr>
<th>Producto</th><th>Cant</th><th>Precio</th><th>Subtotal</th><th>Acción</th>
</tr></thead>
<tbody>

<%
double totalVenta=0;
try(Conexion cn=new Conexion()){
    for(String key:carrito.keySet()){
        Map<String,Object> item=carrito.get(key);
        int id=(int)item.get("id");
        int cant=(int)item.get("cantidad");
        double precioU=(double)item.get("precio");

        ResultSet rs=cn.ConsultaSeguro("SELECT nombre FROM tb_producto WHERE id_producto=?",id);
        rs.next();
        String nombre=rs.getString("nombre");

        double subt=cant*precioU;
        totalVenta+=subt;
%>

<tr class="filaCarrito" data-id="<%=key%>" data-cant="<%=cant%>">
<td><%=nombre%></td>
<td><%=cant%></td>
<td>$<%=precioU%></td>
<td>$<%=subt%></td>
<td><a href="ventas.jsp?accion=eliminar&id=<%=key%>" class="btn btn-danger btn-sm">Eliminar</a></td>
</tr>

<script>bajarStock(<%=id%>,<%=cant%>);</script>

<% }} %>

</tbody>
</table>

<h3 class="text-end">Total: $<%=totalVenta%></h3>

</div>
</div>

<!-- ================= FINALIZAR ================= -->
<div class="text-end mb-4">
<form action="ventas.jsp" method="post" class="d-inline">
<input type="hidden" name="accion" value="finalizar">
<button id="btnFinalizar" class="btn btn-primary btn-lg">Finalizar (Ctrl+F)</button>
</form>

<form action="ventas.jsp" method="post" class="d-inline">
<input type="hidden" name="accion" value="limpiar">
<button class="btn btn-secondary btn-lg">Limpiar (Ctrl+L)</button>
</form>
</div>

<!-- ================= ATAJOS ================= -->
<div class="atajos card shadow">
<div class="card-header bg-primary text-white">Atajos</div>
<div class="card-body">
<table class="table table-sm">
<tr><td>Ctrl+A</td><td>Agregar</td></tr>
<tr><td>Ctrl+F</td><td>Finalizar</td></tr>
<tr><td>Ctrl+L</td><td>Limpiar</td></tr>
<tr><td>Ctrl+C</td><td>Ir a código</td></tr>
<tr><td>Ctrl+D</td><td>Eliminar último</td></tr>
<tr><td>Ctrl+E</td><td>Editar último</td></tr>
<tr><td>Ctrl+B</td><td>Buscar modal</td></tr>
<tr><td>Ctrl+U</td><td>Últimas ventas</td></tr>
</table>
</div>
</div>

<!-- ================= MODAL EDITAR ================= -->
<div class="modal fade" id="modalEditar">
<div class="modal-dialog"><div class="modal-content">
<form method="post">
<div class="modal-header"><h5>Editar</h5><button class="btn-close" data-bs-dismiss="modal"></button></div>
<div class="modal-body">
<input type="hidden" name="accion" value="editar">
<input type="hidden" id="id_edit" name="id_edit">
<label>Nueva cantidad</label>
<input type="number" id="cantidad_edit" name="cantidad_edit" class="form-control" min="1">
</div>
<div class="modal-footer"><button class="btn btn-primary">Guardar</button></div>
</form>
</div></div></div>

<!-- ================= MODAL BUSCAR ================= -->
<div class="modal fade" id="modalBuscar">
<div class="modal-dialog modal-lg"><div class="modal-content">
<div class="modal-header"><h5>Buscar productos</h5><button class="btn-close" data-bs-dismiss="modal"></button></div>
<div class="modal-body">
<input type="text" id="buscarInput" class="form-control mb-2" placeholder="Buscar..." onkeyup="filtrarProductos()">

<table class="table table-hover" id="tablaBuscar">
<thead><tr><th>Código</th><th>Nombre</th><th>Precio</th><th>Stock</th></tr></thead>
<tbody>
<%
try(Conexion cn=new Conexion()){
ResultSet rs=cn.Consulta("SELECT * FROM tb_producto WHERE activo=true ORDER BY nombre");
while(rs.next()){
%>
<tr onclick="seleccionarBusqueda('<%=rs.getInt("id_producto")%>','<%=rs.getDouble("precio_venta")%>')">
<td><%=rs.getString("codigo_barra")%></td>
<td><%=rs.getString("nombre")%></td>
<td>$<%=rs.getDouble("precio_venta")%></td>
<td><%=rs.getInt("cantidad")%></td>
</tr>
<%
}}
%>
</tbody>
</table>

</div></div></div></div>

<!-- ================= MODAL ÚLTIMAS VENTAS ================= -->
<div class="modal fade" id="modalUltimas">
<div class="modal-dialog"><div class="modal-content">
<div class="modal-header"><h5>Últimas ventas</h5><button class="btn-close" data-bs-dismiss="modal"></button></div>
<div class="modal-body">
<table class="table table-bordered">
<thead><tr><th>Fecha</th><th>Total</th><th>ID</th></tr></thead>
<tbody>
<%
try(Conexion cn=new Conexion()){
ResultSet rs=cn.Consulta("SELECT * FROM tb_venta ORDER BY id_venta DESC LIMIT 3");
while(rs.next()){
%>
<tr>
<td><%=rs.getString("fecha")%></td>
<td>$<%=rs.getDouble("total")%></td>
<td>#<%=rs.getInt("id_venta")%></td>
</tr>
<%
}}
%>
</tbody>
</table>
</div></div></div></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</div>
</body>
</html>
