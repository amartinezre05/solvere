# Roadmap — Solvere (Planificador Financiero)

> Documento vivo. Aquí guardamos el análisis y las decisiones a medida que avanzamos. Se actualiza en cada sesión de trabajo.

## Visión

Planificador financiero personal enfocado en el contexto colombiano. Primer módulo: gestión de **créditos** (vivienda, vehículo, libre inversión, etc.) con el detalle suficiente para calcular cuotas, costo total del crédito y seguimiento de saldo. Más adelante: presupuestos, cuentas y transacciones.

---

## Decisiones de arquitectura

| Fecha | Decisión | Razón |
|---|---|---|
| 2026-07-16 | Rails 8.1 + PostgreSQL, creado en el directorio actual | Stack solicitado, sin duplicar carpetas |
| 2026-07-16 | RSpec en vez de Minitest | Preferencia del usuario |
| 2026-07-16 | FactoryBot para datos de prueba | Complementa RSpec, estándar de facto |
| 2026-07-16 | `CreditType` como tabla propia (no enum fijo) | Cada tipo de crédito trae reglas distintas (garantía, beneficio tributario); una tabla permite agregar tipos y ajustar reglas sin deploy de código |
| 2026-07-16 | Soporte a UVR desde el inicio | Los créditos de vivienda en Colombia suelen estar denominados en UVR; se necesita tabla de valores históricos de UVR para conversión a pesos |
| 2026-07-16 | Seguros como modelo `InsurancePolicy` aparte (no campos en `Credit`) | Un crédito puede tener varias pólizas (vida deudor + incendio/terremoto en vivienda, todo riesgo en vehículo), cada una con aseguradora, monto y vigencia propios |
| 2026-07-16 | Multi-usuario con autenticación desde el inicio | Evita migración posterior; cada crédito pertenece a un `User` |
| 2026-07-16 | Plan de amortización se calcula en caliente (servicio), no se persiste como tabla | Cambia con abonos a capital y con actualizaciones de tasa variable; persistirlo obligaría a regenerarlo constantemente |
| 2026-07-16 | Vistas 100% Hotwire (Turbo + Stimulus), sin API/SPA separada | Preferencia del usuario; server-rendered con actualizaciones parciales vía Turbo Frames/Streams |

---

## Fase 0 — Fundamentos del proyecto ✅

- [x] Rails 8.1 + PostgreSQL
- [x] RSpec instalado, reemplaza Minitest
- [x] FactoryBot instalado e integrado en `rails_helper.rb`
- [x] Autenticación (generador de auth de Rails 8: `User`, `Session`, login/logout/reset de contraseña)
  - Sin registro público (sign up) por decisión: usuarios se crean por `bin/rails db:seed` (lee `ADMIN_EMAIL`/`ADMIN_PASSWORD` de ENV) o por consola
  - Se agregó `validates :email_address, uniqueness: true` en `User` (el generador solo deja el índice único en BD, no la validación de modelo)
  - Specs de `User` completos (presencia de password, unicidad de email, normalización, cascada de `sessions` al destruir)

---

## Fase 1 — Módulo de Créditos

### Modelo de dominio (borrador)

**`User`**
- Generado por el auth generator de Rails 8 (email, password digest, sesiones).

**`CreditType`** — catálogo de tipos de crédito
- `name` (ej: "Vivienda VIS", "Vivienda No VIS", "Vehículo", "Libre inversión", "Educativo", "Consumo", "Microcrédito")
- `slug`
- `requires_collateral` (boolean) — si típicamente exige garantía real
- `tax_deductible` (boolean) — si los intereses son deducibles de renta (aplica a vivienda en Colombia, con tope anual definido por la DIAN)
- `description`

**`Credit`** — belongs_to `:user`, `:credit_type`
- `lender_name` — entidad financiera (string por ahora; podría evolucionar a modelo `Lender` si se necesita más adelante)
- `principal_amount` — monto total del préstamo
- `currency` — enum `cop` / `uvr`
- `uvr_value_at_disbursement` — valor de la UVR el día del desembolso (nil si `currency: cop`)
- `term_months` — plazo en meses
- `interest_rate_type` — enum `fixed` / `variable`
- `interest_rate_ea` — tasa efectiva anual (E.A.), la forma estándar en que los bancos colombianos cotizan
- `variable_rate_index` — enum `ibr` / `uvr` / `none` (indexador cuando la tasa es variable; DTF prácticamente en desuso)
- `variable_rate_spread` — puntos adicionales sobre el indexador (ej: IBR + 4%)
- `amortization_system` — enum `cuota_fija` (sistema francés, el más común) / `abono_constante` (sistema alemán)
- `down_payment` — cuota inicial (aplica en vivienda/vehículo, nullable)
- `disbursement_date`
- `first_payment_date`
- `payment_day` — día del mes en que se paga la cuota
- `grace_period_months` — período de gracia (común en educativos)
- `notary_fees` — gastos notariales (vivienda)
- `registration_fees` — gastos de registro (vivienda)
- `appraisal_fee` — avalúo
- `origination_fee` — comisión de apertura/estudio
- `management_fee` — cuota de manejo mensual
- `gmf_applicable` — boolean, si aplica el 4x1000 sobre desembolsos/pagos
- `collateral_type` — enum `hipoteca` / `prenda` / `ninguna`
- `collateral_description` — dirección del inmueble, placa del vehículo, etc.
- `subsidy_amount` — subsidio de vivienda (ej: Mi Casa Ya), nullable
- `status` — enum `active` / `paid_off` / `defaulted` / `written_off`
- `notes`

**`InsurancePolicy`** — belongs_to `:credit`
- `policy_type` — enum `vida_deudor` / `todo_riesgo` / `incendio_terremoto` / `desempleo` / `other`
- `insurer_name`
- `premium_amount`
- `premium_frequency` — enum `monthly` / `annual` / `single`
- `start_date`
- `end_date`

**`UvrValue`** — tabla de valores históricos de UVR (independiente de `Credit`)
- `date`
- `value`
- Fuente: valores certificados por el Banco de la República (se pueden cargar manualmente o vía import/seed inicialmente)

**`Payment`** — belongs_to `:credit`. Registro real de dinero movido (no proyección).
- `payment_date`
- `payment_type` — enum `installment` (cuota regular) / `extra_principal` (abono a capital) / `full_settlement` (pago total anticipado)
- `amount` — total pagado
- `principal_component` — cuánto abonó a capital
- `interest_component` — cuánto fue interés
- `insurance_component` — nullable, si la cuota incluye seguro
- `fees_component` — nullable, cuota de manejo u otros cobros incluidos
- `balance_after` — saldo de capital inmediatamente después de este pago (snapshot histórico)
- `notes`

**`Credits::AmortizationSchedule`** — servicio (PORO, no tabla). Dado un crédito y sus `payments`, calcula el saldo actual (`principal_amount` − Σ `principal_component`) y proyecta las cuotas futuras restantes según `amortization_system` (francés/alemán) y la tasa vigente. No se persiste porque cambia con cada abono a capital y, en tasa variable, con cada actualización del IBR. Se usa para mostrar "próximas cuotas esperadas" y para pre-llenar el desglose interés/capital al registrar un `Payment`.

> Decisión: el desglose interés/capital de cada `Payment` **sí se guarda** (no se recalcula después), porque depende de la tasa vigente en ese momento (relevante en tasa variable) y porque para vivienda se necesita el interés pagado por año fiscal para la deducción de renta ante la DIAN.

### Descartado para esta iteración

No relevantes por ahora (se retoman solo si se vuelven un bloqueo real):
- Tope de deducción de intereses de vivienda en la DIAN por año fiscal
- Fuente/import de valores históricos de UVR
- Histórico de valores de IBR

### UI / Vistas (Hotwire)

Todas las vistas del módulo de créditos se construyen con Turbo + Stimulus (sin SPA/API separada). Vistas identificadas:

1. **`credits#index`** — lista de créditos del usuario con resumen (tipo, entidad, saldo actual, próxima cuota).
2. **`credits#show`** — vista principal de un crédito: datos generales, pólizas de seguro asociadas, y dos bloques clave:
   - **Plan de amortización**: tabla generada por `Credits::AmortizationSchedule`, cruzando lo proyectado (cuota, interés, capital, saldo) con lo realmente pagado (marca las cuotas ya cubiertas por un `Payment`).
   - **Histórico de pagos**: listado real de `Payment` (fecha, tipo, monto, desglose).
3. **`credits#new` / `credits#edit`** — formulario de crédito. Candidato a un Stimulus controller que muestre la cuota estimada en vivo mientras se llenan monto/tasa/plazo/sistema (sin guardar aún), llamando a un endpoint liviano que corre el cálculo del sistema francés.
4. **`payments#new` / `payments#create`** (nested en `credit`) — formulario para registrar un pago. Se abre inline dentro de `credits#show` vía **Turbo Frame** (sin navegar fuera de la página); al guardar, un **Turbo Stream** agrega la fila al histórico de pagos, actualiza el saldo actual y refresca la fila correspondiente del plan de amortización.
5. **Pólizas de seguro** — CRUD simple nested en `credits#show`, también vía Turbo Frames para edición inline.

Convención: mutaciones que afectan varias secciones de `credits#show` (registrar pago, agregar seguro) responden con Turbo Stream; formularios de una sola sección pueden ser Turbo Frame simple.

### Por construir

- [ ] Migraciones: `credit_types`, `credits`, `insurance_policies`, `uvr_values`, `payments`
- [ ] Seeds de `CreditType` con los tipos comunes en Colombia
- [ ] Modelos + validaciones + specs (RSpec + FactoryBot)
- [ ] Servicio `Credits::AmortizationSchedule` (cálculo de cuota sistema francés + proyección)
- [ ] Vista `credits#index`
- [ ] Vista `credits#show` con plan de amortización + histórico de pagos
- [ ] Formulario `credits#new`/`edit` (con Stimulus para cuota estimada en vivo)
- [ ] Formulario `payments#new` inline (Turbo Frame) + actualización vía Turbo Stream

---

## Fases futuras (sin detallar aún)

- Cuentas y transacciones
- Presupuestos por categoría
- Dashboard financiero general
