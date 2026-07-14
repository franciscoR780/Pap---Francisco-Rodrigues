<%-- 
    Document   : validarLogin
    Created on : 11/12/2025, 14:53:01
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String email = request.getParameter("email");
    String palavraPasse = request.getParameter("palavra_passe");
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        String url = "jdbc:mysql://localhost:3306/pap?useSSL=false&serverTimezone=UTC";
        String usuario = "root";
        String senha = "";
        
        conn = DriverManager.getConnection(url, usuario, senha);
        
        String sql = "SELECT id_utilizador, primeiro_nome, ultimo_nome, email, tipo_utilizador FROM t_utilizadores WHERE email = ? AND palavra_passe = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, email);
        pstmt.setString(2, palavraPasse);
        
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            Integer idUtilizador = rs.getInt("id_utilizador");
            String primeiroNome = rs.getString("primeiro_nome");
            String ultimoNome = rs.getString("ultimo_nome");
            String emailUtilizador = rs.getString("email");
            String tipoUtilizador = rs.getString("tipo_utilizador");
            
            Boolean isAdmin = "admin".equalsIgnoreCase(tipoUtilizador);
            
            session.setAttribute("id_utilizador", idUtilizador);
            session.setAttribute("primeiro_nome", primeiroNome);
            session.setAttribute("ultimo_nome", ultimoNome);
            session.setAttribute("email", emailUtilizador);
            session.setAttribute("tipo_utilizador", tipoUtilizador);
            session.setAttribute("is_admin", isAdmin);
            
            if (isAdmin) {
                response.sendRedirect("admin.jsp");
            } else {
                response.sendRedirect("index.htm");
            }
        } else {
            response.sendRedirect("erro.jsp");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("erro.jsp");
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>