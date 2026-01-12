// =======================================================
// VARIABLES GLOBALES
// =======================================================
let carrito = [];

const inputBuscar = document.getElementById("buscarProducto");
const inputCantidad = document.getElementById("cantidad");
const listaAuto = document.getElementById("listaAutocompletado");
const tablaCarrito = document.querySelector("#tablaCarrito tbody");
const totalVenta = document.getElementById("totalVenta");

// =======================================================
// AUTOCOMPLETADO (BUSCADOR PRINCIPAL)
// =======================================================
inputBuscar.addEventListener("input", function () {
    const term = this.value.trim().toLowerCase();

    if (term.length < 1) {
        listaAuto.innerHTML = "";
        return;
    }

    fetch(`ventas.jsp?accion=buscar&term=${term}`)
        .then(r => r.json())
        .then(lista => {
            listaAuto.innerHTML = "";

            lista.forEach(p => {
                const item = document.createElement("div");
                item.classList.add("item-autocompletar");
                item.innerHTML = `${p.nombre} | ${p.codigo} | Stock:${p.stock}`;

                item.onclick = () => seleccionarProducto(p);
                listaAuto.appendChild(item);
            });
        });
});

function seleccionarProducto(p) {
    inputBuscar.value = p.nombre;

    inputBuscar.dataset.id = p.id;
    inputBuscar.dataset.precio = p.precio;
    inputBuscar.dataset.stock = p.stock;

    listaAuto.innerHTML = "";
    inputCantidad.focus();
}


// =======================================================
// BOTÓN AGREGAR
// =======================================================
document.getElementById("btnAgregar").onclick = agregar;

function agregar() {
    const id = inputBuscar.dataset.id;
    const precio = parseFloat(inputBuscar.dataset.precio || 0);
    const stock = parseInt(inputBuscar.dataset.stock || 0);
    const nombre = inputBuscar.value.trim();
    const cant = parseInt(inputCantidad.value);

    if (!id) {
        alert("Seleccione un producto válido");
        return;
    }

    if (cant > stock) {
        alert("Stock insuficiente");
        return;
    }

    carrito.push({
        id,
        nombre,
        precio,
        cantidad: cant,
        total: precio * cant
    });

    dibujarCarrito();

    // Limpiar selección
    inputBuscar.value = "";
    inputBuscar.dataset.id = "";
    inputBuscar.dataset.precio = "";
    inputBuscar.dataset.stock = "";
    inputCantidad.value = 1;
    inputBuscar.focus();
}


// =======================================================
// TABLA DEL CARRITO
// =======================================================
function dibujarCarrito() {
    tablaCarrito.innerHTML = "";
    let total = 0;

    carrito.forEach((item, i) => {
        total += item.total;

        tablaCarrito.innerHTML += `
            <tr>
                <td>${item.id}</td>
                <td>${item.nombre}</td>
                <td>${item.cantidad}</td>
                <td>$${item.precio}</td>
                <td>$${item.total.toFixed(2)}</td>
                <td>
                    <button class="btn btn-danger btn-sm" onclick="eliminar(${i})">X</button>
                </td>
            </tr>
        `;
    });

    totalVenta.innerText = total.toFixed(2);
}

function eliminar(index) {
    carrito.splice(index, 1);
    dibujarCarrito();
}


// =======================================================
// MODAL DE BÚSQUEDA
// =======================================================
document.getElementById("buscarEnModal").addEventListener("input", function () {
    const term = this.value.trim().toLowerCase();
    const contenedor = document.getElementById("listaModal");

    fetch(`ventas.jsp?accion=buscar&term=${term}`)
        .then(r => r.json())
        .then(lista => {
            contenedor.innerHTML = "";

            lista.forEach(p => {
                contenedor.innerHTML += `
                    <tr class="fila-modal"
                        data-id="${p.id}"
                        data-nombre="${p.nombre}"
                        data-stock="${p.stock}"
                        data-precio="${p.precio}">
                        <td>${p.nombre}</td>
                        <td>${p.codigo}</td>
                        <td>${p.stock}</td>
                        <td>$${p.precio}</td>
                    </tr>
                `;
            });

            document.querySelectorAll(".fila-modal").forEach(fila => {
                fila.onclick = () => {
                    seleccionarProducto({
                        id: fila.dataset.id,
                        nombre: fila.dataset.nombre,
                        stock: fila.dataset.stock,
                        precio: fila.dataset.precio
                    });

                    const modal = bootstrap.Modal.getInstance(document.getElementById("modalBuscar"));
                    modal.hide();
                };
            });
        });
});


// =======================================================
// ATAJOS DEL TECLADO
// =======================================================
document.addEventListener("keydown", (e) => {

    if (e.key === "Enter") {
        e.preventDefault();
        agregar();
    }

    if (e.key === "F2") {
        e.preventDefault();
        document.getElementById("buscarEnModal").focus();
        const modal = new bootstrap.Modal(document.getElementById("modalBuscar"));
        modal.show();
    }

    if (e.key === "F1") {
        e.preventDefault();
        registrar();
    }

    if (e.key === "Escape") {
        carrito.pop();
        dibujarCarrito();
    }

});


// =======================================================
// REGISTRAR VENTA
// =======================================================
document.getElementById("btnRegistrar").onclick = registrar;

function registrar() {
    if (carrito.length === 0) {
        alert("El carrito está vacío");
        return;
    }

    const form = new FormData();
    form.append("accion", "guardarVenta");
    form.append("carrito", JSON.stringify(carrito));

    fetch("ventas.jsp", {
        method: "POST",
        body: form
    })
        .then(r => r.text())
        .then(msg => {
            alert(msg);
            carrito = [];
            dibujarCarrito();
        });
}
