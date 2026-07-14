<%--
    Document   : Login
    Created on : 28/10/2025, 09:17:44
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.PasswordUtil" %>
<%
    String mensagemLogin = "";
    String tipoMensagemLogin = "";
    
    if (request.getMethod().equals("POST") && "login".equals(request.getParameter("acao"))) {
        String email = request.getParameter("email");
        String palavra_passe = request.getParameter("palavra_passe");
        String captchaInput = request.getParameter("captcha");
        
        // VALIDAR CAPTCHA PRIMEIRO
        String captchaCode = (String) session.getAttribute("captcha");
        
        if (captchaCode == null || !captchaCode.equalsIgnoreCase(captchaInput)) {
            mensagemLogin = "CAPTCHA inválido! Tente novamente.";
            tipoMensagemLogin = "error";
        } else {
            // Remover CAPTCHA da sessão após validação
            session.removeAttribute("captcha");
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
                
                // ⚡ NOVO: Buscar APENAS pelo email primeiro
                String sql = "SELECT * FROM t_utilizadores WHERE email = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, email);
                
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    // VERIFICAR SE O EMAIL FOI VERIFICADO
                    boolean emailVerificado = rs.getBoolean("email_verificado");
                    
                    if (!emailVerificado) {
                        mensagemLogin = "Por favor, verifica o teu email antes de fazer login!";
                        tipoMensagemLogin = "error";
                    } else {
                        // ⚡ NOVO: Buscar o hash da password da BD
                        String senhaHash = rs.getString("palavra_passe");
                        
                        // ⚡ NOVO: Verificar se a password inserida corresponde ao hash
                        if (PasswordUtil.checkPassword(palavra_passe, senhaHash)) {
                            // LOGIN VÁLIDO - GUARDAR NA SESSÃO
                            session.setAttribute("id_utilizador", rs.getInt("id_utilizador"));
                            session.setAttribute("primeiro_nome", rs.getString("primeiro_nome"));
                            session.setAttribute("ultimo_nome", rs.getString("ultimo_nome"));
                            session.setAttribute("email", rs.getString("email"));
                            session.setAttribute("tipo_utilizador", rs.getString("tipo_utilizador"));
                            
                            // Verificar se é admin
                            String tipoUtilizador = rs.getString("tipo_utilizador");
                            boolean isAdmin = tipoUtilizador.equals("admin");
                            session.setAttribute("is_admin", isAdmin);
                            
                            // Redirecionar para a página principal
                            response.sendRedirect("index.htm");
                        } else {
                            mensagemLogin = "Email ou palavra-passe incorretos!";
                            tipoMensagemLogin = "error";
                        }
                    }
                } else {
                    mensagemLogin = "Email ou palavra-passe incorretos!";
                    tipoMensagemLogin = "error";
                }
                
                rs.close();
                stmt.close();
                conn.close();
                
            } catch (Exception e) {
                mensagemLogin = "Erro: " + e.getMessage();
                tipoMensagemLogin = "error";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SC Rio Tinto - Login</title>
    <link href="css/CssLogin.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">
                <img src="images/Logo SCRT.jpg" alt="SC Rio Tinto">
            </div>
            <h1>Login</h1>
            <p class="subtitle">Bem-vindo de volta!</p>
        </div>

        <% if (!mensagemLogin.isEmpty()) { %>
            <div class="message-box <%= tipoMensagemLogin %>">
                <i class="fas fa-<%= tipoMensagemLogin.equals("success") ? "check-circle" : "exclamation-circle" %>"></i>
                <%= mensagemLogin %>
            </div>
        <% } %>

        <form method="post">
            <input type="hidden" name="acao" value="login">

            <div class="form-group">
                <label for="email">Email *</label>
                <input type="email" name="email" id="email" required>
            </div>

            <div class="form-group">
                <label for="palavra_passe">Palavra-passe *</label>
                <input type="password" name="palavra_passe" id="palavra_passe" required>
            </div>

            <div class="form-group">
                <label>CAPTCHA *</label>
                <div class="captcha-container">
                    <img id="captchaImage" src="captcha" alt="CAPTCHA" class="captcha-image">
                    <button type="button" class="refresh-btn" onclick="refreshCaptcha()" title="Gerar novo código">
                        <i class="fas fa-sync-alt"></i>
                    </button>
                </div>
            </div>

            <div class="form-group">
                <label for="captcha">Digite o código acima *</label>
                <input type="text" id="captcha" name="captcha" required autocomplete="off" maxlength="6">
            </div>

            <button type="submit" class="btn-submit">
                <i class="fas fa-sign-in-alt"></i> Entrar
            </button>
        </form>

        <div class="footer-link">
            Não tens conta? <a href="Registro.jsp">Cria uma aqui</a><br>
            Esqueceste a senha? <a href="RecuperarSenha.jsp">Recuperar senha</a>
        </div>
    </div>
    
    <script>
        function refreshCaptcha() {
            document.getElementById('captchaImage').src = 'captcha?' + new Date().getTime();
        }
    </script>
</body>
</html>