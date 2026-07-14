<%--
    Document   : logout
    Created on : 27/10/2025, 16:11:06
    Author     : Francisco
--%>


<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Invalidar a sessão
    session.invalidate();
    
    // Redirecionar para a página inicial
    response.sendRedirect("index.htm");
%>
