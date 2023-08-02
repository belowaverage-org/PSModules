Add-Type -AssemblyName System.Windows.Forms

$form = [System.Windows.Forms.Form]::new()
$form.Width = 800
$form.Height = 600

$btnClose = [System.Windows.Forms.Button]::new()
$btnClose.Text = "Close"
$btnClose.Parent = $form
$btnClose.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
$btnClose.FlatStyle = [System.Windows.Forms.FlatStyle]::System
$btnClose.Location = [System.Drawing.Point]::new($form.Width - 100, $form.Height - 70)

$btnHehe = [System.Windows.Forms.Button]::new()
$btnHehe.Text = "Hehehe"
$btnHehe.Parent = $form
$btnHehe.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right
$btnHehe.FlatStyle = [System.Windows.Forms.FlatStyle]::System
$btnHehe.Location = [System.Drawing.Point]::new($form.Width - 190, $form.Height - 70)

$textbox = [System.Windows.Forms.RichTextBox]::new()
$textbox.Parent = $form
$textbox.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Top
$textbox.Width = $form.Width - 16
$textbox.Height = $form.Height - 80
$textbox.Font = [System.Drawing.Font]::new([System.Drawing.FontFamily]::GenericMonospace, 10)


$btnHehe.add_Click({
    $textBox.Clear()
    $textBox.Text += Get-Process | Out-String
})


$btnClose.add_Click({
    $form.Close()
})


$form.ShowDialog()