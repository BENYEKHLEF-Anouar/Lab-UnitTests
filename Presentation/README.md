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
    line-height: 1.6;
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
  h2 { color: #088dc7; font-size: 2em; border-bottom: 2px solid #088dc7; margin-bottom: 40px; }
  h3 { text-align: left; color: #444; margin-top: 0; }

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

  section > p > img {
    display: block;
    margin: 0 auto;
    object-fit: contain;
    border-radius: 10px;
    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
  }

  .dt-card {
    background: #f0f7fa;
    padding: 30px;
    border-radius: 10px;
    border-top: 6px solid #088dc7;
    text-align: left;
    margin-top: 20px;
    width: 100%;
  }

  /* Couleurs de la pile technique */
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
  .maquette-grid {
    display: flex;
    gap: 15px;
    justify-content: center;
    align-items: flex-start;
    height: 350px;
  }

  .context-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-top: 10px;
  }
  .context-card {
    background: #f4faff;
    border-radius: 10px;
    padding: 20px 25px;
    border-left: 5px solid #088dc7;
  }
  .context-card h4 { color: #088dc7; margin: 0 0 10px 0; }
  .problem-card {
    background: #fff5f5;
    border-left-color: #e74c3c;
  }
  .problem-card h4 { color: #e74c3c; }

  /* Cartes premium pour empathie / idéation */
  .persona-card {
    background: #ffffff;
    padding: 18px;
    border-radius: 14px;
    box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
    border-top: 5px solid #088dc7;
    transition: transform 0.3s ease;
  }
  .persona-card strong { font-size: 1.1em; display: block; margin-bottom: 8px; }
  .persona-card p { font-size: 0.85em; margin: 0; color: #555; line-height: 1.4; }

  .ideation-badge {
    display: inline-block;
    padding: 4px 10px;
    border-radius: 20px;
    font-size: 0.75em;
    font-weight: bold;
    margin-right: 5px;
    margin-bottom: 5px;
  }

---

<div class="logo-header">
  <img src="images/ofppt-logo.png" alt="Logo OFPPT">
  <img src="images/logo-solicode.png" alt="Logo SoliCode">
</div>

# **Abstraction et architecture par interface**
### Pour des tests unitaires propres et maintenables dans Laravel

**Réalisé par :** <span class="highlight">BENYEKHLEF Anouar</span>  
**Encadré par :** <span class="highlight">M. ESSARRAJ Fouad</span>

---


## Pourquoi l'abstraction par interface ?

- Rendre le code **testable**
- Respecter le **principe de dépendance inversée** (DIP - SOLID)
- Faciliter le **mocking** dans les tests
- Améliorer la **maintenabilité** et la **flexibilité**

---

## Problème courant sans abstraction

```php
// Mauvaise pratique
class OrderService
{
    public function createOrder(array $data)
    {
        $payment = new StripePaymentGateway(); // Couplage fort !
        $payment->charge($data['amount']);

        // ...
    }
}
```

Très difficile à tester unitairement.

---

## Solution : architecture par interface

```php
// 1. Créer l'interface
interface PaymentGatewayInterface
{
    public function charge(float $amount, string $token): PaymentResult;
    public function refund(string $transactionId): bool;
}

// 2. Implémentation concrète
class StripePaymentGateway implements PaymentGatewayInterface
{
    public function charge(float $amount, string $token): PaymentResult
    {
        // Appel à l'API Stripe
    }
}
```

---

## Injection via le constructeur

```php
class OrderService
{
    private PaymentGatewayInterface $paymentGateway;

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

---

## Configuration dans le conteneur de services

```php
// app/Providers/AppServiceProvider.php
public function register()
{
    $this->app->bind(
        PaymentGatewayInterface::class,
        StripePaymentGateway::class
    );
}
```

---

## Test unitaire avec mock

```php
use Mockery;
use Tests\TestCase;
use App\Services\OrderService;
use App\Contracts\PaymentGatewayInterface;

class OrderServiceTest extends TestCase
{
    public function test_create_order_charges_payment()
    {
        // Mock de l'interface
        $mockGateway = Mockery::mock(PaymentGatewayInterface::class);
        $mockGateway->shouldReceive('charge')
                    ->once()
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

- Tests **rapides** sans appel API réel
- Tests **fiables** sans dépendance externe
- Code **plus propre** et **découplé**
- Changement d'implémentation simplifié (`Stripe`, `PayPal`, `CIB`, etc.)

---

## Bonnes pratiques recommandées

1. Placer les interfaces dans `app/Contracts/`
2. Nommer les interfaces avec le suffixe `Interface`
3. Toujours injecter les abstractions, jamais les classes concrètes
4. Utiliser l'injection par constructeur
5. Tester le comportement, pas l'implémentation

---

## Résumé

**L'abstraction par interface permet :**

- une meilleure **testabilité**
- une meilleure **maintenabilité**
- le respect des **principes SOLID**
- une architecture **moderne** et **professionnelle**


