<?php
// Inclui a biblioteca do Mercado Pago
require_once 'vendor/autoload.php';

// **COLOQUE O SEU ACCESS TOKEN AQUI**
// Este é o passo mais importante. Pegue o seu token no painel do Mercado Pago.
MercadoPago\SDK::setAccessToken("APP_USR-2872879530029605-071212-7a2b0edf82f7fdfed99973e6d044681d-288062953");

// Pega os dados que o formulário enviou
$nome_cliente = $_POST['cli_nome'];
$email_cliente = $_POST['cli_email'];
$cpf_cliente = preg_replace('/[^0-9]/', '', $_POST['cli_cpf']); // Remove pontos e traços do CPF
$nome_plano = $_POST['pacote_nome'];
$preco_plano = (float)$_POST['pacote_preco'];

// Cria o objeto de pagamento
$payment = new MercadoPago\Payment();
$payment->transaction_amount = $preco_plano;
$payment->description = $nome_plano;
$payment->payment_method_id = "pix";

// Define os dados do pagador (cliente)
$payment->payer = array(
    "email" => $email_cliente,
    "first_name" => explode(' ', $nome_cliente)[0], // Pega o primeiro nome
    "last_name" => end(explode(' ', $nome_cliente)), // Pega o último nome
    "identification" => array(
        "type" => "CPF",
        "number" => $cpf_cliente
     )
);

// Salva o pagamento para gerar o PIX
$payment->save();

// Se deu tudo certo, pega os dados do PIX
if ($payment->id) {
    $qr_code_base64 = $payment->point_of_interaction->transaction_data->qr_code_base64;
    $qr_code_copia_cola = $payment->point_of_interaction->transaction_data->qr_code;
} else {
    // Se deu erro, exibe uma mensagem
    echo "Ocorreu um erro ao gerar o PIX. Tente novamente.";
    exit;
}

?>

<!-- Agora, exibe a página com o QR Code para o cliente pagar -->
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Pague com Pix</title>
    <style>
        body { font-family: 'Montserrat', sans-serif; text-align: center; padding-top: 40px; }
        .container { max-width: 400px; margin: auto; }
        h1 { margin-bottom: 20px; }
        img { display: block; margin: 20px auto; }
        .copia-cola {
            word-wrap: break-word;
            background: #eee;
            padding: 15px;
            border-radius: 6px;
            margin-bottom: 20px;
        }
        button {
            padding: 12px 20px;
            background: #009ee3;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 1rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Pague com Pix para liberar seu plano!</h1>
        <p>Escaneie o QR Code abaixo com o app do seu banco:</p>
        <img src="data:image/jpeg;base64,<?php echo $qr_code_base64; ?>" alt="QR Code Pix" />
        
        <p>Ou copie o código abaixo:</p>
        <div class="copia-cola" id="pixCopiaCola"><?php echo $qr_code_copia_cola; ?></div>
        <button onclick="copiarPix()">Copiar Código Pix</button>
    </div>

    <script>
        function copiarPix() {
            const texto = document.getElementById('pixCopiaCola').innerText;
            navigator.clipboard.writeText(texto).then(() => {
                alert('Código PIX copiado com sucesso!');
            });
        }
    </script>
</body>
</html>
