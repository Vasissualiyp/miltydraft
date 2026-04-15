<?php

declare(strict_types=1);

namespace App\Mail;

use PHPMailer\PHPMailer\PHPMailer;

class Mailer
{
    public function __construct(
        private readonly string $host,
        private readonly int    $port,
        private readonly string $username,
        private readonly string $password,
        private readonly string $fromAddress,
        private readonly string $fromName,
        private readonly string $encryption,
    ) {
    }

    public function sendTurnNotification(
        string $toAddress,
        string $toName,
        string $draftUrl,
        string $draftName,
    ): void {
        $m = new PHPMailer(true);
        $m->isSMTP();
        $m->Timeout = 5;
        $m->Host = $this->host;
        $m->Port = $this->port;
        $m->SMTPAuth = true;
        $m->Username = $this->username;
        $m->Password = $this->password;
        $m->SMTPSecure = $this->encryption === 'ssl'
            ? PHPMailer::ENCRYPTION_SMTPS
            : PHPMailer::ENCRYPTION_STARTTLS;
        $m->setFrom($this->fromAddress, $this->fromName);
        $m->addAddress($toAddress, $toName);
        $m->Subject = "It's your turn in {$draftName}!";
        $m->isHTML(false);
        $m->Body =
            "Hi {$toName},\n\n" .
            "It's your turn to pick in the Milty Draft \"{$draftName}\".\n\n" .
            "Open the draft here: {$draftUrl}\n\n" .
            "Good luck!\n";
        $m->send();
    }
}
