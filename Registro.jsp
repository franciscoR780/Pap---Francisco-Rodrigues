<%--
    Document   : Registro
    Created on : 19/11/2025, 18:03:27
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Random" %>
<%@ page import="util.EmailUtil" %>
<%@ page import="util.PasswordUtil" %>
<%
    String mensagem = "";
    String tipoMensagem = "";
    String passo = "dados"; // dados -> codigo -> completo
    String emailAtual = "";
    
    if (request.getMethod().equals("POST")) {
        String acao = request.getParameter("acao");
        
        // PASSO 1: Registar dados e enviar código
        if ("registrar".equals(acao)) {
            String primeiro_nome = request.getParameter("primeiro_nome");
            String ultimo_nome = request.getParameter("ultimo_nome");
            String email = request.getParameter("email");
            String telefone = request.getParameter("telefone");
            String palavra_passe = request.getParameter("palavra_passe");
            String confirmar_passe = request.getParameter("confirmar_passe");
            String data_nascimento = request.getParameter("data_nascimento");
            String captchaInput = request.getParameter("captcha");
            
            // VALIDAR CAPTCHA PRIMEIRO
            String captchaCode = (String) session.getAttribute("captcha");
            
            if (captchaCode == null || !captchaCode.equalsIgnoreCase(captchaInput)) {
                mensagem = "CAPTCHA inválido! Tente novamente.";
                tipoMensagem = "error";
            } else if (!palavra_passe.equals(confirmar_passe)) {
                mensagem = "As palavras-passe não coincidem!";
                tipoMensagem = "error";
            } else {
                // Remover CAPTCHA da sessão após validação
                session.removeAttribute("captcha");
                
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
                    
                    // Verificar se email já existe
                    String checkSql = "SELECT * FROM t_utilizadores WHERE email = ?";
                    PreparedStatement checkStmt = conn.prepareStatement(checkSql);
                    checkStmt.setString(1, email);
                    ResultSet rs = checkStmt.executeQuery();
                    
                    if (rs.next()) {
                        mensagem = "Este email já está registado!";
                        tipoMensagem = "error";
                    } else {
                        // Gerar código de 6 dígitos
                        Random rand = new Random();
                        String codigo = String.format("%06d", rand.nextInt(1000000));
                        
                        // ⚡ NOVO: Fazer hash da password e do código de verificação
                        String senhaHash = PasswordUtil.hashPassword(palavra_passe);
                        String codigoHash = PasswordUtil.hashPassword(codigo);
                        
                        // Inserir utilizador com email NÃO verificado e password HASH
                        String sql = "INSERT INTO t_utilizadores (primeiro_nome, ultimo_nome, email, telefone, tipo_utilizador, palavra_passe, data_nascimento, email_verificado, codigo_verificacao, data_codigo_verificacao) VALUES (?, ?, ?, ?, 'adepto', ?, ?, 0, ?, NOW())";
                        PreparedStatement stmt = conn.prepareStatement(sql);
                        stmt.setString(1, primeiro_nome);
                        stmt.setString(2, ultimo_nome);
                        stmt.setString(3, email);
                        stmt.setString(4, telefone);
                        stmt.setString(5, senhaHash);  // ⚡ Password com HASH
                        stmt.setString(6, data_nascimento);
                        stmt.setString(7, codigoHash);  // ⚡ Código com HASH
                        
                        int rowsInserted = stmt.executeUpdate();
                        if (rowsInserted > 0) {
                            // ENVIAR EMAIL com código em texto simples
                            boolean emailEnviado = EmailUtil.enviarEmailVerificacao(email, primeiro_nome, codigo);
                            
                            if (emailEnviado) {
                                mensagem = "Código de verificação enviado para " + email;
                                tipoMensagem = "success";
                                passo = "codigo";
                                emailAtual = email;
                            } else {
                                mensagem = "Conta criada mas falhou o envio do email. Código: " + codigo;
                                tipoMensagem = "error";
                                passo = "codigo";
                                emailAtual = email;
                            }
                        }
                        stmt.close();
                    }
                    
                    rs.close();
                    checkStmt.close();
                    conn.close();
                    
                } catch (Exception e) {
                    mensagem = "Erro: " + e.getMessage();
                    tipoMensagem = "error";
                }
            }
        }
        
        // PASSO 2: Validar código de verificação
        else if ("validar_codigo".equals(acao)) {
            String email = request.getParameter("email_hidden");
            String codigoInserido = request.getParameter("codigo");
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
                
                // ⚡ NOVO: Buscar o hash do código
                String sql = "SELECT id_utilizador, primeiro_nome, codigo_verificacao FROM t_utilizadores " +
                            "WHERE email = ? " +
                            "AND data_codigo_verificacao > DATE_SUB(NOW(), INTERVAL 30 MINUTE) " +
                            "AND email_verificado = 0";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, email);
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    int idUtilizador = rs.getInt("id_utilizador");
                    String codigoHash = rs.getString("codigo_verificacao");
                    
                    // ⚡ NOVO: Verificar se o código inserido corresponde ao hash
                    if (PasswordUtil.checkPassword(codigoInserido, codigoHash)) {
                        // Marcar email como verificado
                        String updateSql = "UPDATE t_utilizadores SET email_verificado = 1, codigo_verificacao = NULL, data_codigo_verificacao = NULL WHERE id_utilizador = ?";
                        PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                        updateStmt.setInt(1, idUtilizador);
                        updateStmt.executeUpdate();
                        updateStmt.close();
                        
                        mensagem = "Email verificado com sucesso! Redirecionando para o login...";
                        tipoMensagem = "success";
                        response.setHeader("Refresh", "3;url=Login.jsp");
                    } else {
                        mensagem = "Código inválido!";
                        tipoMensagem = "error";
                        passo = "codigo";
                        emailAtual = email;
                    }
                } else {
                    mensagem = "Código expirado ou email inválido!";
                    tipoMensagem = "error";
                    passo = "codigo";
                    emailAtual = email;
                }
                
                rs.close();
                stmt.close();
                conn.close();
            } catch (Exception e) {
                mensagem = "Erro: " + e.getMessage();
                tipoMensagem = "error";
                passo = "codigo";
                emailAtual = email;
            }
        }
        
        // Reenviar código
        else if ("reenviar_codigo".equals(acao)) {
            String email = request.getParameter("email_hidden");
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
                
                // Buscar utilizador
                String sql = "SELECT id_utilizador, primeiro_nome FROM t_utilizadores WHERE email = ? AND email_verificado = 0";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, email);
                ResultSet rs = stmt.executeQuery();
                
                if (rs.next()) {
                    int idUtilizador = rs.getInt("id_utilizador");
                    String primeiroNome = rs.getString("primeiro_nome");
                    
                    // Gerar novo código
                    Random rand = new Random();
                    String novoCodigo = String.format("%06d", rand.nextInt(1000000));
                    
                    // ⚡ NOVO: Fazer hash do novo código
                    String novoCodigoHash = PasswordUtil.hashPassword(novoCodigo);
                    
                    // Atualizar código HASH na BD
                    String updateSql = "UPDATE t_utilizadores SET codigo_verificacao = ?, data_codigo_verificacao = NOW() WHERE id_utilizador = ?";
                    PreparedStatement updateStmt = conn.prepareStatement(updateSql);
                    updateStmt.setString(1, novoCodigoHash);
                    updateStmt.setInt(2, idUtilizador);
                    updateStmt.executeUpdate();
                    updateStmt.close();
                    
                    // Enviar novo email com código em texto simples
                    boolean emailEnviado = EmailUtil.enviarEmailVerificacao(email, primeiroNome, novoCodigo);
                    
                    if (emailEnviado) {
                        mensagem = "Novo código enviado para " + email;
                        tipoMensagem = "success";
                    } else {
                        mensagem = "Falhou o envio do email. Novo código: " + novoCodigo;
                        tipoMensagem = "error";
                    }
                    passo = "codigo";
                    emailAtual = email;
                }
                
                rs.close();
                stmt.close();
                conn.close();
            } catch (Exception e) {
                mensagem = "Erro: " + e.getMessage();
                tipoMensagem = "error";
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SC Rio Tinto - Criar Conta</title>
    <link href="css/CssRegistro.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">
                <img src="images/Logo SCRT.jpg" alt="SC Rio Tinto">
            </div>
            <h1>Criar Conta</h1>
            <p class="subtitle">
                <% if (passo.equals("dados")) { %>
                    Junta-te à família SC Rio Tinto
                <% } else if (passo.equals("codigo")) { %>
                    Verifica o teu email para continuar
                <% } %>
            </p>
        </div>

        <div class="progress-steps">
            <div class="step <%= passo.equals("dados") ? "active" : "completed" %>">1</div>
            <div class="step <%= passo.equals("codigo") ? "active" : "" %>">2</div>
        </div>

        <% if (!mensagem.isEmpty()) { %>
            <div class="message-box <%= tipoMensagem %>">
                <i class="fas fa-<%= tipoMensagem.equals("success") ? "check-circle" : "exclamation-circle" %>"></i>
                <%= mensagem %>
            </div>
        <% } %>

        <% if (passo.equals("dados")) { %>
            <form method="post">
                <input type="hidden" name="acao" value="registrar">

                <div class="form-row">
                    <div class="form-group">
                        <label for="primeiro_nome">Primeiro Nome *</label>
                        <input type="text" name="primeiro_nome" id="primeiro_nome" required>
                    </div>

                    <div class="form-group">
                        <label for="ultimo_nome">Último Nome *</label>
                        <input type="text" name="ultimo_nome" id="ultimo_nome" required>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="email">Email *</label>
                        <input type="email" name="email" id="email" required>
                    </div>

                    <div class="form-group">
                        <label for="telefone">Telefone</label>
                        <input type="tel" name="telefone" id="telefone" placeholder="9xxxxxxxx">
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="palavra_passe">Palavra-passe *</label>
                        <input type="password" name="palavra_passe" id="palavra_passe" required minlength="6">
                    </div>

                    <div class="form-group">
                        <label for="confirmar_passe">Confirmar Palavra-passe *</label>
                        <input type="password" name="confirmar_passe" id="confirmar_passe" required minlength="6">
                    </div>
                </div>

                <div class="form-group full-width">
                    <label for="data_nascimento">Data de Nascimento *</label>
                    <input type="date" name="data_nascimento" id="data_nascimento" required>
                </div>

                <div class="form-group full-width">
                    <label>CAPTCHA *</label>
                    <div class="captcha-container">
                        <img id="captchaImage" src="captcha" alt="CAPTCHA" class="captcha-image">
                        <button type="button" class="refresh-btn" onclick="refreshCaptcha()" title="Gerar novo código">
                            <i class="fas fa-sync-alt"></i>
                        </button>
                    </div>
                </div>

                <div class="form-group full-width">
                    <label for="captcha">Digite o código acima *</label>
                    <input type="text" id="captcha" name="captcha" required autocomplete="off" maxlength="6">
                </div>

                <button type="submit" class="btn-submit">
                    <i class="fas fa-user-plus"></i> Criar Conta
                </button>
            </form>
        <% } %>

        <% if (passo.equals("codigo")) { %>
            <% if (!emailAtual.isEmpty()) { %>
                <div class="message-box info">
                    <i class="fas fa-envelope"></i>
                    Código enviado para: <%= emailAtual %>
                </div>
            <% } %>
            
            <form method="post">
                <input type="hidden" name="acao" value="validar_codigo">
                <input type="hidden" name="email_hidden" value="<%= emailAtual %>">
                
                <div class="form-group">
                    <label for="codigo">Código de Verificação *</label>
                    <input type="text" name="codigo" id="codigo" required 
                           maxlength="6" pattern="[0-9]{6}" 
                           class="codigo-input" placeholder="000000" autocomplete="off">
                </div>
                
                <button type="submit" class="btn-submit">
                    <i class="fas fa-check"></i> Verificar Email
                </button>
            </form>

            <form method="post" style="margin-top: 1rem;">
                <input type="hidden" name="acao" value="reenviar_codigo">
                <input type="hidden" name="email_hidden" value="<%= emailAtual %>">
                <button type="submit" class="btn-submit btn-secondary">
                    <i class="fas fa-redo"></i> Reenviar Código
                </button>
            </form>
        <% } %>

        <div class="footer-link">
            Já tens conta? <a href="Login.jsp">Faz login aqui</a>
        </div>
    </div>

    <script>
        function refreshCaptcha() {
            document.getElementById('captchaImage').src = 'captcha?' + new Date().getTime();
        }
        
        <% if (passo.equals("codigo")) { %>
            document.getElementById('codigo').focus();
        <% } %>
    </script>
</body>
</html>