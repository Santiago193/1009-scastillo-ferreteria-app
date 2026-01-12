package com.ferreteria.admin;

import com.ferreteria.datos.Conexion;
import java.sql.*;
import java.util.*;

public class Compra {

    private int id;
    private String proveedor;
    private String producto;
    private int cantidad;
    private double precio;
    private double total;
    private String fecha;
    private String marca;
    private String codigo;

    public String getMarca() { return marca; }
    public String getCodigo() { return codigo; }

    // ============================
    // LISTAR COMPRAS
    // ============================
    public static List<Compra> listar() {

        List<Compra> lista = new ArrayList<>();

        String sql = """
            SELECT c.id_compra,
                   pr.nombre AS proveedor,
                   p.nombre AS producto,
                   d.cantidad,
                   d.precio_compra AS precio,
                   (d.cantidad * d.precio_compra) AS total,
                   c.fecha
            FROM tb_compra c
            JOIN tb_compra_detalle d ON c.id_compra = d.id_compra
            JOIN tb_producto p ON p.id_producto = d.id_producto
            JOIN tb_proveedor pr ON pr.id_proveedor = c.id_proveedor
            ORDER BY c.id_compra DESC
        """;

        try (Conexion cx = new Conexion();
             PreparedStatement ps = cx.getConexion().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Compra c = new Compra();

                c.id = rs.getInt("id_compra");
                c.proveedor = rs.getString("proveedor");
                c.producto = rs.getString("producto");
                c.cantidad = rs.getInt("cantidad");
                c.precio = rs.getDouble("precio");
                c.total = rs.getDouble("total");
                c.fecha = rs.getString("fecha");

                lista.add(c);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }

    // GETTERS
    public int getId() { return id; }
    public String getProveedor() { return proveedor; }
    public String getProducto() { return producto; }
    public int getCantidad() { return cantidad; }
    public double getPrecio() { return precio; }
    public double getTotal() { return total; }
    public String getFecha() { return fecha; }

    // ============================
    // REGISTRAR COMPRA
    // ============================
    public static void registrar(int proveedor, int producto, int cantidad, double precio) {

        String sqlCompra = """
            INSERT INTO tb_compra (id_proveedor, total)
            VALUES (?, ?)
            RETURNING id_compra
        """;

        String sqlDetalle = """
            INSERT INTO tb_compra_detalle (id_compra, id_producto, cantidad, precio_compra)
            VALUES (?, ?, ?, ?)
        """;

        String sqlPP = """
            INSERT INTO tb_producto_proveedor(id_producto, id_proveedor, precio_compra)
            VALUES (?, ?, ?)
            ON CONFLICT (id_producto, id_proveedor)
            DO UPDATE SET precio_compra = EXCLUDED.precio_compra
        """;

        try (Conexion con = new Conexion()) {

            Connection cx = con.getConexion();

            // 1. INSERTAR COMPRA
            PreparedStatement psC = cx.prepareStatement(sqlCompra);
            psC.setInt(1, proveedor);
            psC.setDouble(2, cantidad * precio);
            ResultSet rs = psC.executeQuery();

            int idCompra = 0;
            if (rs.next()) idCompra = rs.getInt("id_compra");

            // 2. INSERTAR DETALLE
            PreparedStatement psD = cx.prepareStatement(sqlDetalle);
            psD.setInt(1, idCompra);
            psD.setInt(2, producto);
            psD.setInt(3, cantidad);
            psD.setDouble(4, precio);
            psD.executeUpdate();

            // ❌ ***ELIMINADO*** UPDATE DEL STOCK
            // Los triggers hacen esto automáticamente

            // 3. ACTUALIZAR PRECIO X PROVEEDOR
            PreparedStatement psPP = cx.prepareStatement(sqlPP);
            psPP.setInt(1, producto);
            psPP.setInt(2, proveedor);
            psPP.setDouble(3, precio);
            psPP.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
