<%--
    Document   : logout_admin
    Created on : 03/11/2025, 14:02:58
    Author     : Francisco
--%>


<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Destruir a sessão
    session.invalidate();
    
    // Redirecionar para o login
    response.sendRedirect("login_admin.jsp");
%>