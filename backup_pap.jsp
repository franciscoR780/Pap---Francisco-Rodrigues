<%@ page import="java.io.*, java.text.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <title>Backup — SC Rio Tinto</title>
    <link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=DM+Mono:wght@300;400;500&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --red:    #e63946;
            --red2:   #ff6b6b;
            --glass:  rgba(255,255,255,0.05);
            --border: rgba(255,255,255,0.10);
            --text:   #f0f0f0;
            --muted:  rgba(255,255,255,0.45);
        }

        body {
            font-family: 'Syne', sans-serif;
            background: #050508;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            position: relative;
        }

        .bg { position: fixed; inset: 0; z-index: 0; overflow: hidden; }
        .blob {
            position: absolute;
            border-radius: 50%;
            filter: blur(100px);
            opacity: 0.35;
            animation: drift 12s ease-in-out infinite alternate;
        }
        .blob1 { width: 520px; height: 520px; background: #e63946; top: -160px; left: -160px; animation-duration: 14s; }
        .blob2 { width: 400px; height: 400px; background: #6a0572; bottom: -120px; right: -100px; animation-duration: 10s; animation-delay: -4s; }
        .blob3 { width: 300px; height: 300px; background: #1a1a6e; top: 40%; left: 50%; animation-duration: 18s; animation-delay: -8s; }

        @keyframes drift {
            from { transform: translate(0, 0) scale(1); }
            to   { transform: translate(40px, 30px) scale(1.08); }
        }

        .grid-overlay {
            position: fixed; inset: 0; z-index: 1;
            background-image:
                linear-gradient(rgba(255,255,255,0.025) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255,255,255,0.025) 1px, transparent 1px);
            background-size: 40px 40px;
        }

        .card {
            position: relative; z-index: 10;
            width: 100%; max-width: 560px;
            margin: 20px;
            background: var(--glass);
            backdrop-filter: blur(28px) saturate(180%);
            -webkit-backdrop-filter: blur(28px) saturate(180%);
            border: 1px solid var(--border);
            border-radius: 24px;
            padding: 44px 40px 36px;
            text-align: center;
            box-shadow: 0 0 0 1px rgba(255,255,255,0.04),
                        0 32px 80px rgba(0,0,0,0.6),
                        inset 0 1px 0 rgba(255,255,255,0.08);
            animation: cardIn 0.7s cubic-bezier(0.22, 1, 0.36, 1) both;
        }
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(30px) scale(0.97); }
            to   { opacity: 1; transform: translateY(0) scale(1); }
        }

        .badge {
            display: inline-flex; align-items: center; gap: 7px;
            background: rgba(230,57,70,0.15);
            border: 1px solid rgba(230,57,70,0.35);
            color: var(--red2);
            padding: 6px 18px;
            border-radius: 100px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            margin-bottom: 22px;
        }

        h1 {
            color: var(--text);
            font-size: 30px;
            font-weight: 800;
            letter-spacing: -0.02em;
            line-height: 1.2;
            margin-bottom: 10px;
        }
        h1 span { color: var(--red); }

        .subtitle {
            font-family: 'DM Mono', monospace;
            color: var(--muted);
            font-size: 11.5px;
            font-weight: 300;
            letter-spacing: 0.07em;
            margin-bottom: 30px;
        }

        .divider {
            height: 1px;
            background: linear-gradient(90deg, transparent, var(--border), transparent);
            margin: 0 0 28px;
        }

        .resultado {
            border-radius: 14px;
            padding: 20px 22px;
            text-align: left;
            font-size: 13px;
            line-height: 1.9;
            margin-bottom: 16px;
            animation: fadeUp 0.5s ease both;
        }
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(12px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .sucesso {
            background: rgba(39,174,96,0.10);
            border: 1px solid rgba(39,174,96,0.22);
            color: #a3ffcb;
        }
        .sucesso .title-res { color: #5effa5; font-size: 14px; font-weight: 700; margin-bottom: 12px; }

        .erro {
            background: rgba(230,57,70,0.10);
            border: 1px solid rgba(230,57,70,0.25);
            color: #ffb3b3;
        }
        .erro .title-res { color: var(--red2); font-size: 14px; font-weight: 700; margin-bottom: 12px; }

        .info {
            background: rgba(255,255,255,0.03);
            border: 1px solid rgba(255,255,255,0.07);
            color: var(--muted);
            font-family: 'DM Mono', monospace;
            font-size: 11px;
            word-break: break-all;
            padding: 14px 18px;
        }

        .row {
            display: flex;
            align-items: baseline;
            gap: 10px;
            padding: 2px 0;
            font-family: 'DM Mono', monospace;
            font-size: 12px;
        }
        .row .lbl {
            color: var(--muted);
            min-width: 80px;
            font-size: 10.5px;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            flex-shrink: 0;
        }
        .row .val { color: inherit; font-weight: 500; word-break: break-all; }

        .btn-wrap { margin-top: 6px; }
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            background: linear-gradient(135deg, #e63946 0%, #b5001e 100%);
            color: #fff;
            border: none;
            padding: 14px 40px;
            font-family: 'Syne', sans-serif;
            font-size: 13.5px;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            border-radius: 100px;
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            box-shadow: 0 4px 30px rgba(230,57,70,0.40);
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 45px rgba(230,57,70,0.60);
        }
        .btn:active { transform: scale(0.97); }

        pre {
            background: rgba(0,0,0,0.4);
            border: 1px solid rgba(255,255,255,0.06);
            border-radius: 8px;
            padding: 10px 14px;
            font-size: 11px;
            font-family: 'DM Mono', monospace;
            color: #ffaaaa;
            overflow-x: auto;
            margin-top: 10px;
            white-space: pre-wrap;
        }

        code {
            background: rgba(255,255,255,0.07);
            padding: 2px 7px;
            border-radius: 4px;
            font-family: 'DM Mono', monospace;
            font-size: 11px;
            color: #ffd6a5;
        }
    </style>
</head>
<body>

<div class="bg">
    <div class="blob blob1"></div>
    <div class="blob blob2"></div>
    <div class="blob blob3"></div>
</div>
<div class="grid-overlay"></div>

<div class="card">
    <div class="badge">SC Rio Tinto</div>
    <h1>Backup da<br><span>Base de Dados</span></h1>
    <p class="subtitle">DB: PAP &nbsp;·&nbsp; HOST: 127.0.0.1 &nbsp;·&nbsp; MariaDB 10.4</p>
    <div class="divider"></div>

    <%
        // ============================================================
        // CONFIGURAÇÕES
        // ============================================================
        String dbHost     = "127.0.0.1";
        String dbPort     = "3306";
        String dbName     = "pap";
        String dbUser     = "root";
        String dbPassword = "";

        String pastaBackup     = "C:/Users/Aluno/Desktop/Muita coisa/PAP/PAP-20260114T094127Z-1-001/PAP/backups/";
        String timestamp       = new SimpleDateFormat("yyyyMMdd_HHmmss").format(new Date());
        String nomeFile        = "backup_pap_" + timestamp + ".sql";
        String caminhoCompleto = pastaBackup + nomeFile;
        // ============================================================

        File pasta = new File(pastaBackup);
        if (!pasta.exists()) { pasta.mkdirs(); }

        List<String> comando = new ArrayList<>();
        comando.add("C:\\xampp\\mysql\\bin\\mysqldump.exe");
        comando.add("-h"); comando.add(dbHost);
        comando.add("-P"); comando.add(dbPort);
        comando.add("-u"); comando.add(dbUser);
        if (!dbPassword.isEmpty()) { comando.add("--password=" + dbPassword); }
        comando.add("--single-transaction");
        comando.add("--routines");
        comando.add("--triggers");
        comando.add("--add-drop-table");
        comando.add("--result-file=" + caminhoCompleto);
        comando.add(dbName);

        ProcessBuilder pb = new ProcessBuilder(comando);
        pb.redirectErrorStream(true);

        try {
            long inicio = System.currentTimeMillis();
            Process processo = pb.start();
            BufferedReader reader = new BufferedReader(new InputStreamReader(processo.getInputStream()));
            StringBuilder saida = new StringBuilder();
            String linha;
            while ((linha = reader.readLine()) != null) { saida.append(linha).append("\n"); }

            int codigoSaida = processo.waitFor();
            long duracao    = System.currentTimeMillis() - inicio;

            if (codigoSaida == 0) {
                File f = new File(caminhoCompleto);
                long tamanhoKB = f.exists() ? f.length() / 1024 : 0;
    %>
        <div class="resultado sucesso">
            <div class="title-res">✅ Backup criado com sucesso!</div>
            <div class="row"><span class="lbl">Ficheiro</span><span class="val"><%= nomeFile %></span></div>
            <div class="row"><span class="lbl">Localização</span><span class="val"><%= caminhoCompleto %></span></div>
            <div class="row"><span class="lbl">Tamanho</span><span class="val"><%= tamanhoKB %> KB</span></div>
            <div class="row"><span class="lbl">Duração</span><span class="val"><%= duracao %> ms</span></div>
            <div class="row"><span class="lbl">Data/Hora</span><span class="val"><%= new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(new Date()) %></span></div>
        </div>
    <%
            } else {
    %>
        <div class="resultado erro">
            <div class="title-res">❌ Erro ao criar o backup</div>
            <div class="row"><span class="lbl">Exit code</span><span class="val"><%= codigoSaida %></span></div>
            <% if (saida.length() > 0) { %><pre><%= saida.toString() %></pre><% } %>
        </div>
    <%
            }
        } catch (IOException e) {
    %>
        <div class="resultado erro">
            <div class="title-res">❌ Erro ao executar o comando</div>
            <%= e.getMessage() %><br><br>
            💡 Verifica se o mysqldump está em <code>C:\xampp\mysql\bin\mysqldump.exe</code>
        </div>
    <%
        } catch (InterruptedException e) {
    %>
        <div class="resultado erro">
            <div class="title-res">❌ Processo interrompido</div>
            <%= e.getMessage() %>
        </div>
    <%
        }
    %>

    <div class="resultado info">
        📂 &nbsp;<%= pastaBackup %>
    </div>

    <div class="btn-wrap">
        <form method="get">
            <button class="btn" type="submit">↻ &nbsp;Novo Backup</button>
        </form>
    </div>
</div>

</body>
</html>
