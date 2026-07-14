<%--
    Document   : confirmacao
    Created on : 11/11/2025, 12:48:36
    Author     : Francisco
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="javax.mail.*" %>
<%@ page import="javax.mail.internet.*" %>
<%@ page import="java.util.Properties" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // OBTER PARÂMETROS DA URL
    String idEncomenda = request.getParameter("encomenda");
    String numeroFatura = request.getParameter("fatura");
    
    // VARIÁVEIS PARA ARMAZENAR OS DADOS
    String emailUtilizador = "";
    String nomeUtilizador = "";
    double valorTotal = 0.0;
    double subtotal = 0.0;
    double iva = 0.0;
    String metodoPagamento = "";
    String moradaEnvio = "";
    String dataEncomenda = "";
    String codigoRastreio = "";
    String numeroEncomenda = "";
    
    // ✅ 1. BUSCAR DADOS DA ENCOMENDA NA BASE DE DADOS
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
        
        // Query para buscar detalhes da encomenda (SEM subtotal e iva)
        String sql = "SELECT e.id_encomenda, e.id_utilizador, e.valor_total, e.metodo_pagamento, " +
                     "e.morada_envio, e.data_encomenda, e.numero_encomenda, e.codigo_rastreio, " +
                     "u.email, u.primeiro_nome, u.ultimo_nome " +
                     "FROM t_encomendas e " +
                     "INNER JOIN t_utilizadores u ON e.id_utilizador = u.id_utilizador " +
                     "WHERE e.id_encomenda = ?";
        
        PreparedStatement stmt = conn.prepareStatement(sql);
        stmt.setString(1, idEncomenda);
        ResultSet rs = stmt.executeQuery();
        
        if (rs.next()) {
            emailUtilizador = rs.getString("email");
            nomeUtilizador = rs.getString("primeiro_nome") + " " + rs.getString("ultimo_nome");
            valorTotal = rs.getDouble("valor_total");
            
            // 🧮 CALCULAR SUBTOTAL E IVA A PARTIR DO VALOR TOTAL
            // Assumindo que valor_total já inclui IVA de 23%
            subtotal = valorTotal / 1.23;
            iva = valorTotal - subtotal;
            
            metodoPagamento = rs.getString("metodo_pagamento") != null ? rs.getString("metodo_pagamento") : "";
            moradaEnvio = rs.getString("morada_envio") != null ? rs.getString("morada_envio") : "";
            dataEncomenda = rs.getString("data_encomenda") != null ? rs.getString("data_encomenda") : "";
            numeroEncomenda = rs.getString("numero_encomenda") != null ? rs.getString("numero_encomenda") : idEncomenda;
            codigoRastreio = rs.getString("codigo_rastreio") != null ? rs.getString("codigo_rastreio") : "";
        }
        
        rs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p style='color:red;'>Erro ao buscar dados: " + e.getMessage() + "</p>");
    }
    
    // ✅ 2. ENVIAR EMAIL COM A FATURA
    boolean emailEnviado = false;
    
    try {
        // Configuração do servidor SMTP
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        
        // ⚠️ ALTERAR ESTAS CREDENCIAIS
        final String username = "scrxllclaude123@gmail.com"; // ⚠️ ALTERAR
        final String password = "pvbw tjwi jnzi mrgc"; // ⚠️ ALTERAR (App Password do Gmail)
        
        Session mailSession = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
        
        // Criar mensagem
        Message message = new MimeMessage(mailSession);
        message.setFrom(new InternetAddress(username));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(emailUtilizador));
        message.setSubject("✅ Confirmação de Encomenda #" + numeroEncomenda + " - SC Rio Tinto");
        
        // Corpo do email em HTML
        String htmlContent = 
            "<html>" +
            "<head>" +
            "<style>" +
            "body { font-family: Arial, sans-serif; color: #333; margin: 0; padding: 0; background: #f5f5f5; }" +
            ".container { max-width: 600px; margin: 20px auto; background: white; border-radius: 15px; overflow: hidden; box-shadow: 0 5px 20px rgba(0,0,0,0.1); }" +
            ".header { background: linear-gradient(135deg, #FFD700, #e6c200); padding: 30px; text-align: center; }" +
            ".header h1 { margin: 0; color: #000; font-size: 28px; }" +
            ".success-icon { font-size: 60px; margin-bottom: 10px; }" +
            ".content { padding: 30px; }" +
            ".greeting { font-size: 18px; margin-bottom: 20px; }" +
            ".details { background: #f9f9f9; border-radius: 10px; padding: 20px; margin: 20px 0; }" +
            ".detail-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #e0e0e0; }" +
            ".detail-row:last-child { border-bottom: none; }" +
            ".label { font-weight: 600; color: #666; }" +
            ".value { font-weight: 700; color: #000; text-align: right; }" +
            ".total-section { background: linear-gradient(135deg, #FFD700, #e6c200); padding: 20px; margin: 20px 0; border-radius: 10px; }" +
            ".total-row { display: flex; justify-content: space-between; font-size: 24px; font-weight: bold; color: #000; }" +
            ".footer { text-align: center; padding: 20px; background: #f5f5f5; color: #666; font-size: 12px; }" +
            ".button { display: inline-block; background: #000; color: #FFD700; padding: 15px 30px; border-radius: 50px; text-decoration: none; font-weight: bold; margin: 20px 0; }" +
            "</style>" +
            "</head>" +
            "<body>" +
            "<div class='container'>" +
            "<div class='header'>" +
            "<div class='success-icon'>✅</div>" +
            "<h1>Compra Realizada com Sucesso!</h1>" +
            "</div>" +
            "<div class='content'>" +
            "<p class='greeting'>Olá <strong>" + nomeUtilizador + "</strong>,</p>" +
            "<p>Obrigado pela sua compra! A sua encomenda foi registada com sucesso.</p>" +
            "<div class='details'>" +
            "<div class='detail-row'>" +
            "<span class='label'># Número da Encomenda:</span>" +
            "<span class='value'>#" + numeroEncomenda + "</span>" +
            "</div>" +
            "<div class='detail-row'>" +
            "<span class='label'>📄 Número da Fatura:</span>" +
            "<span class='value'>" + numeroFatura + "</span>" +
            "</div>" +
            (codigoRastreio.isEmpty() ? "" : 
            "<div class='detail-row'>" +
            "<span class='label'>📦 Código de Rastreio:</span>" +
            "<span class='value'>" + codigoRastreio + "</span>" +
            "</div>") +
            "<div class='detail-row'>" +
            "<span class='label'>📅 Data:</span>" +
            "<span class='value'>" + dataEncomenda + "</span>" +
            "</div>" +
            "<div class='detail-row'>" +
            "<span class='label'>💳 Método de Pagamento:</span>" +
            "<span class='value'>" + metodoPagamento + "</span>" +
            "</div>" +
            "<div class='detail-row'>" +
            "<span class='label'>📍 Morada de Envio:</span>" +
            "<span class='value'>" + moradaEnvio + "</span>" +
            "</div>" +
            "</div>" +
            "<div class='details'>" +
            "<div class='detail-row'>" +
            "<span class='label'>Subtotal:</span>" +
            "<span class='value'>" + String.format("%.2f€", subtotal) + "</span>" +
            "</div>" +
            "<div class='detail-row'>" +
            "<span class='label'>IVA (23%):</span>" +
            "<span class='value'>" + String.format("%.2f€", iva) + "</span>" +
            "</div>" +
            "</div>" +
            "<div class='total-section'>" +
            "<div class='total-row'>" +
            "<span>TOTAL:</span>" +
            "<span>" + String.format("%.2f€", valorTotal) + "</span>" +
            "</div>" +
            "</div>" +
            "<p style='text-align: center; color: #666;'>" +
            "Receberá uma notificação quando a sua encomenda for enviada." +
            "</p>" +
            "</div>" +
            "<div class='footer'>" +
            "<p style='margin: 5px 0;'><strong>SC Rio Tinto</strong></p>" +
            "<p style='margin: 5px 0;'>Obrigado pela sua preferência!</p>" +
            "<p style='margin: 5px 0; color: #999;'>Este é um email automático, por favor não responda.</p>" +
            "</div>" +
            "</div>" +
            "</body>" +
            "</html>";
        
        message.setContent(htmlContent, "text/html; charset=utf-8");
        
        // Enviar email
        Transport.send(message);
        emailEnviado = true;
        
    } catch (Exception e) {
        out.println("<p style='color:red;'>Erro ao enviar email: " + e.getMessage() + "</p>");
    }
    
    // ✅ 3. ATUALIZAR ESTADO DA ENCOMENDA QUANDO CLICAR EM CONFIRMAR
    if (request.getParameter("confirmar") != null && request.getParameter("confirmar").equals("true")) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/pap", "root", "");
            
            // Atualizar estado para 'comprado'
            String sqlUpdate = "UPDATE t_encomendas SET estado = 'comprado', data_atualizacao = CURRENT_TIMESTAMP WHERE id_encomenda = ?";
            PreparedStatement stmtUpdate = conn.prepareStatement(sqlUpdate);
            stmtUpdate.setString(1, idEncomenda);
            
            int rows = stmtUpdate.executeUpdate();
            
            if (rows > 0) {
                out.println("<script>alert('✅ Encomenda confirmada! Estado atualizado para COMPRADO.');</script>");
            }
            
            stmtUpdate.close();
            conn.close();
            
        } catch (Exception e) {
            out.println("<p style='color:red;'>Erro ao atualizar estado: " + e.getMessage() + "</p>");
        }
    }
%>

<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Compra Realizada</title>
    <link href="css/CssConfirmacao.css" rel="stylesheet" type="text/css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
</head>
<body>
    <div class="confirmation-card">
        <div class="success-icon">
            <i class="fas fa-check"></i>
        </div>
        
        <h1>Compra Realizada com Sucesso!</h1>
        <p class="subtitle">Obrigado pela sua compra, <%= nomeUtilizador %>!</p>
        
        <% if (emailEnviado) { %>
            <div class="email-status">
                <i class="fas fa-envelope"></i>
                Receberá um email de confirmação em <strong><%= emailUtilizador %></strong> com os detalhes da sua encomenda.
            </div>
        <% } %>
        
        <div class="details">
            <div class="detail-row">
                <span class="label"># Número da Encomenda:</span>
                <span class="value">#<%= numeroEncomenda %></span>
            </div>
            
            <div class="detail-row">
                <span class="label">📄 Número da Fatura:</span>
                <span class="value"><%= numeroFatura %></span>
            </div>
            
            <% if (!codigoRastreio.isEmpty()) { %>
            <div class="detail-row">
                <span class="label">📦 Código de Rastreio:</span>
                <span class="value"><%= codigoRastreio %></span>
            </div>
            <% } %>
            
            <div class="detail-row">
                <span class="label">📅 Data:</span>
                <span class="value"><%= dataEncomenda %></span>
            </div>
            
            <div class="detail-row">
                <span class="label">💳 Método de Pagamento:</span>
                <span class="value"><%= metodoPagamento %></span>
            </div>
            
            <div class="detail-row">
                <span class="label">📍 Morada de Envio:</span>
                <span class="value"><%= moradaEnvio %></span>
            </div>
            
            <div class="detail-row">
                <span class="label">Subtotal:</span>
                <span class="value"><%= String.format("%.2f€", subtotal) %></span>
            </div>
            
            <div class="detail-row">
                <span class="label">IVA (23%):</span>
                <span class="value"><%= String.format("%.2f€", iva) %></span>
            </div>
        </div>
        
        <div class="total-row">
            <span>TOTAL:</span>
            <span><%= String.format("%.2f€", valorTotal) %></span>
        </div>
        
        <div class="buttons">
            <form method="post" action="confirmacao.jsp" style="flex: 1;">
                <input type="hidden" name="encomenda" value="<%= idEncomenda %>">
                <input type="hidden" name="fatura" value="<%= numeroFatura %>">
                <input type="hidden" name="confirmar" value="true">
                <button type="submit" class="btn btn-primary">
                    <i class="fas fa-check-circle"></i> Confirmar Compra
                </button>
            </form>
            
            <button class="btn btn-secondary" onclick="gerarFatura()">
                <i class="fas fa-download"></i> Descarregar PDF
            </button>
                
            <a href="index.htm" class="btn btn-secondary">
                <i class="fas fa-home"></i> Página Inicial
            </a>    
                
        </div>
    </div>
    <!-- Logo oculto para usar no PDF -->
    <img id="logo-clube" src="images/Logo SCRT.jpg" style="display: none;" crossorigin="anonymous">

    <script>
        function gerarFatura() {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF();

            const amarelo = [255, 215, 0];
            const preto   = [10, 10, 10];
            const cinza   = [102, 102, 102];

            // Dados vindos do servidor
            const idEncomenda    = '<%= idEncomenda %>';
            const numEncomenda   = '<%= numeroEncomenda %>';
            const data           = '<%= dataEncomenda %>';
            const morada         = '<%= moradaEnvio.replace("'", "\\'").replace("\n", " ") %>';
            const metodoPagamento = '<%= metodoPagamento %>';
            const subtotal       = <%= subtotal %>;
            const iva            = <%= iva %>;
            const total          = <%= valorTotal %>;
            const nomeCliente    = '<%= nomeUtilizador.replace("'", "\\'") %>';
            const emailCliente   = '<%= emailUtilizador %>';
            const faturaNum      = '<%= numeroFatura %>';

            let y = 20;

            // TÍTULO
            doc.setFontSize(32);
            doc.setTextColor(...preto);
            doc.setFont('helvetica', 'bold');
            doc.text('FATURA', 20, y);

            // LOGO
            try {
                const logoImg = document.getElementById('logo-clube');
                if (logoImg && logoImg.complete) {
                    const canvas = document.createElement('canvas');
                    const ctx = canvas.getContext('2d');
                    canvas.width = logoImg.naturalWidth;
                    canvas.height = logoImg.naturalHeight;
                    ctx.drawImage(logoImg, 0, 0);
                    const logoData = canvas.toDataURL('image/jpeg');
                    doc.addImage(logoData, 'JPEG', 160, 10, 35, 35);
                }
            } catch (error) {
                console.error('Erro ao adicionar logo:', error);
            }

            y = 50;

            // DADOS DO CLUBE
            doc.setFontSize(10);
            doc.setFont('helvetica', 'bold');
            doc.setTextColor(...preto);
            doc.text('SC Rio Tinto', 20, y);
            y += 5;
            doc.setFont('helvetica', 'normal');
            doc.setTextColor(...cinza);
            doc.text('Rua do Clube, 123', 20, y); y += 5;
            doc.text('4435-123 Rio Tinto', 20, y); y += 5;
            doc.text('NIF: 123456789', 20, y);

            // DADOS DO CLIENTE
            y = 50;
            doc.setFont('helvetica', 'bold');
            doc.setTextColor(...preto);
            doc.text('COBRAR A:', 110, y); y += 5;
            doc.setFont('helvetica', 'normal');
            doc.setTextColor(...cinza);
            doc.text(nomeCliente, 110, y); y += 5;
            doc.text(emailCliente, 110, y); y += 5;
            const moradaLinhas = doc.splitTextToSize(morada, 80);
            moradaLinhas.forEach(linha => { doc.text(linha, 110, y); y += 5; });

            // LINHA SEPARADORA + DETALHES
            y = 90;
            doc.setDrawColor(...amarelo);
            doc.setLineWidth(0.5);
            doc.line(20, y, 190, y);
            y += 8;

            doc.setFont('helvetica', 'bold');
            doc.setTextColor(...preto);
            doc.setFontSize(9);
            doc.text('FATURA #', 20, y);
            doc.text('DATA DA FATURA', 70, y);
            doc.text('MÉTODO PAGAMENTO', 120, y);
            y += 5;

            doc.setFont('helvetica', 'normal');
            doc.setTextColor(...cinza);
            doc.text(faturaNum || 'FT-' + String(idEncomenda).padStart(4, '0'), 20, y);
            doc.text(data, 70, y);
            doc.text(metodoPagamento.toUpperCase(), 120, y);

            y += 10;
            doc.setDrawColor(...amarelo);
            doc.line(20, y, 190, y);
            y += 10;

            // TABELA
            doc.setFont('helvetica', 'bold');
            doc.setTextColor(...preto);
            doc.text('QTD', 20, y);
            doc.text('DESCRIÇÃO', 40, y);
            doc.text('PREÇO UNIT.', 120, y);
            doc.text('VALOR', 170, y, { align: 'right' });

            y += 3;
            doc.setDrawColor(...cinza);
            doc.setLineWidth(0.3);
            doc.line(20, y, 190, y);
            y += 7;

            doc.setFont('helvetica', 'normal');
            doc.setTextColor(...cinza);
            doc.text('1', 20, y);
            doc.text('Produtos da encomenda #' + numEncomenda, 40, y);
            doc.text(subtotal.toFixed(2) + '€', 120, y);
            doc.text(subtotal.toFixed(2) + '€', 190, y, { align: 'right' });
            y += 12;

            doc.setDrawColor(...cinza);
            doc.line(20, y, 190, y);
            y += 10;

            // TOTAIS
            doc.setFont('helvetica', 'normal');
            doc.text('Subtotal', 120, y);
            doc.text(subtotal.toFixed(2) + '€', 190, y, { align: 'right' });
            y += 7;

            doc.text('IVA 23.0%', 120, y);
            doc.text(iva.toFixed(2) + '€', 190, y, { align: 'right' });
            y += 10;

            doc.setDrawColor(...amarelo);
            doc.setLineWidth(1);
            doc.line(120, y, 190, y);
            y += 8;

            doc.setFont('helvetica', 'bold');
            doc.setFontSize(14);
            doc.setTextColor(...preto);
            doc.text('TOTAL', 120, y);
            doc.text(total.toFixed(2) + '€', 190, y, { align: 'right' });

            // RODAPÉ
            y = 270;
            doc.setFillColor(...amarelo);
            doc.rect(0, y, 210, 27, 'F');
            y += 8;
            doc.setFontSize(10);
            doc.setFont('helvetica', 'bold');
            doc.setTextColor(...preto);
            doc.text('TERMOS E CONDIÇÕES', 20, y);
            y += 6;
            doc.setFont('helvetica', 'normal');
            doc.setFontSize(8);
            doc.text('Pagamento deve ser efetuado no prazo de 15 dias.', 20, y);
            y += 4;
            doc.text('NIB: PT50 0000 0000 0000 0000 0000 0', 20, y);

            doc.save('Fatura_FT-' + String(idEncomenda).padStart(4, '0') + '_SC_Rio_Tinto.pdf');
        }
    </script>
</body>
</html>