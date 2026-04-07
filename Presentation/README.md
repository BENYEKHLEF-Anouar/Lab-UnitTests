---
marp: true
theme: default
_class: lead
_paginate: false
paginate: true
backgroundColor: #ffffff
style: |
  section {
    font-size: 22px;
    color: #333;
    line-height: 1.7;
    padding: 60px 80px;
  }
  footer { width: 100%; text-align: right; font-size: 14px; color: #888; }
  .logo-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: absolute;
    top: 40px;
    left: 60px;
    right: 60px;
  }
  .logo-header img { height: 140px; margin: 0 10px; }
  h1 { color: #088dc7; font-size: 2.8em; margin-top: 100px; text-align: left; }
  h2 { color: #088dc7; font-size: 2.1em; border-bottom: 2px solid #088dc7; padding-bottom: 15px; }
  h3 { color: #444; margin-top: 0; }

  .highlight { color: #088dc7; font-weight: bold; }

  .sommaire-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-top: 20px;
  }
  .sommaire-item {
    display: flex;
    align-items: center;
    background: #f4faff;
    border-radius: 12px;
    padding: 15px 20px;
    border-left: 5px solid #088dc7;
  }
  .sommaire-num {
    background: #088dc7;
    color: white;
    width: 35px;
    height: 35px;
    display: flex;
    justify-content: center;
    align-items: center;
    border-radius: 50%;
    font-weight: bold;
    margin-right: 15px;
    flex-shrink: 0;
  }

  .dt-card {
    background: #f0f7fa;
    padding: 30px;
    border-radius: 10px;
    border-top: 6px solid #088dc7;
    text-align: left;
    margin-top: 20px;
  }

  .tech-container {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    margin-top: 20px;
  }
  .badge-simple {
    padding: 8px 18px;
    border-radius: 6px;
    font-weight: 600;
    background-color: #545353;
    color: #ffffff !important;
    font-size: 0.85em;
    border: 1px solid #222;
  }

  .context-card {
    background: #f4faff;
    border-radius: 10px;
    padding: 20px 25px;
    border-left: 5px solid #088dc7;
  }
  .problem-card {
    background: #fff5f5;
    border-left-color: #e74c3c;
  }
  .problem-card h4 { color: #e74c3c; }

  .good-example {
    background: #f0f9f0;
    border-left: 5px solid #27ae60;
  }
---

<div class="logo-header">
  <img src="images/ofppt-logo.png" alt="Logo OFPPT">
  <img src="images/logo-solicode.png" alt="Logo SoliCode">
</div>

# **Abstraction et Architecture par Interface**
### Pour des tests unitaires propres et faciles dans Laravel

**Réalisé par :** <span class="highlight">BENYEKHLEF Anouar</span>  
**Encadré par :** <span class="highlight">M. ESSARRAJ Fouad</span>

---

## Objectifs de ce cours

- Comprendre pourquoi le code "collé" (couplé) pose problème
- Découvrir ce qu’est une **interface** en programmation
- Apprendre à utiliser l’**abstraction** pour rendre le code testable
- Voir une architecture propre et professionnelle avec Laravel

---

## Pourquoi utiliser l’abstraction par interface ?

Imaginez que vous construisez une maison :
- Si vous collez directement les briques au mur, c’est très dur de les changer plus tard.
- Si vous utilisez des **vis et des connecteurs**, vous pouvez facilement changer une partie sans casser tout le reste.

**L’interface = le connecteur**

**Avantages :**
- Code plus facile à tester
- Code plus flexible (vous pouvez changer Stripe par PayPal facilement)
- Respect du principe SOLID (DIP)
- Meilleure maintenabilité

---

## Problème courant : Code fortement couplé

```php
// Mauvaise pratique - Très difficile à tester
class OrderService
{
    public function createOrder(array $data)
    {
        $payment = new StripePaymentGateway();   // ← Couplage fort !
        $payment->charge($data['amount']);

        // ...
    }
}
```

**Problèmes :**
- Impossible de tester sans appeler vraiment Stripe
- Si Stripe change ou tombe en panne → tous les tests échouent
- Impossible de tester avec une fausse carte bancaire

---

## Solution : Utiliser une Interface (Le Connecteur)

```php
// 1. Créer l'interface (le contrat)
interface PaymentGatewayInterface
{
    public function charge(float $amount, string $token): PaymentResult;
    public function refund(string $transactionId): bool;
}

// 2. L'implémentation concrète (la vraie classe)
class StripePaymentGateway implements PaymentGatewayInterface
{
    public function charge(float $amount, string $token): PaymentResult
    {
        // Code réel pour appeler Stripe
    }
}
```

> L’interface dit **"ce que doit faire"**, pas **"comment"** il le fait.

---

## Injection via le Constructeur (La Bonne Pratique)

```php
class OrderService
{
    private PaymentGatewayInterface $paymentGateway;

    // Nous demandons l'interface, pas la classe concrète
    public function __construct(PaymentGatewayInterface $paymentGateway)
    {
        $this->paymentGateway = $paymentGateway;
    }

    public function createOrder(array $data)
    {
        $result = $this->paymentGateway->charge(
            $data['amount'], 
            $data['payment_token']
        );

        // ...
    }
}
```

**Maintenant le service ne dépend plus de Stripe, mais d’un "moyen de paiement".**

---

## Enregistrer l’interface dans Laravel (Service Container)

```php
// app/Providers/AppServiceProvider.php
public function register()
{
    $this->app->bind(
        PaymentGatewayInterface::class,   // Interface
        StripePaymentGateway::class       // Implémentation réelle
    );
}
```

Laravel sait maintenant : "Quand quelqu’un demande PaymentGatewayInterface, je lui donne StripePaymentGateway".

---

## Test Unitaire avec Mock (Le plus important !)

```php
use Mockery;
use Tests\TestCase;
use App\Services\OrderService;
use App\Contracts\PaymentGatewayInterface;

class OrderServiceTest extends TestCase
{
    public function test_create_order_charges_payment()
    {
        // Création d'un faux moyen de paiement (Mock)
        $mockGateway = Mockery::mock(PaymentGatewayInterface::class);
        $mockGateway->shouldReceive('charge')
                    ->once()                    // doit être appelé une seule fois
                    ->with(99.99, 'tok_123')
                    ->andReturn(new PaymentResult(true, 'ch_456'));

        $service = new OrderService($mockGateway);

        $result = $service->createOrder([
            'amount' => 99.99,
            'payment_token' => 'tok_123'
        ]);

        $this->assertTrue($result->success);
    }
}
```

---

## Avantages de cette approche

| Avantage              | Sans Interface          | Avec Interface              |
|-----------------------|-------------------------|-----------------------------|
| Testabilité           | Très difficile          | Très facile                 |
| Vitesse des tests     | Lente (appels API)      | Rapide                      |
| Flexibilité           | Difficile à changer     | Très facile (Stripe → PayPal) |
| Maintenabilité        | Compliqué               | Propre et clair             |

---

## Bonnes Pratiques (À toujours respecter)

1. Mettre toutes les interfaces dans `app/Contracts/`
2. Nommer les interfaces avec `Interface` à la fin (`PaymentGatewayInterface`)
3. Toujours demander l’**interface**, jamais la classe concrète
4. Préférer l’injection par **constructeur**
5. Tester le **comportement**, pas l’implémentation interne

---

## Résumé Final

**L’abstraction par interface permet de :**

- Transformer un code **rigide** en code **flexible**
- Rendre les tests unitaires **faciles, rapides et fiables**
- Respecter les bonnes pratiques professionnelles (SOLID)
- Changer facilement de moyen de paiement, de base de données, ou d’API

> **Phrase à retenir :**
> "Programme contre une interface, pas contre une implémentation concrète."

---

## Merci pour votre attention !

**Questions ?**

**Exercice pratique recommandé :**
1. Créer une interface `SmsGatewayInterface`
2. Faire deux implémentations (Twilio et Nexmo)
3. Injecter dans un `NotificationService`
4. Tester avec Mock
  
---

**BON COURAGE !** 
