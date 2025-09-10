import 'package:flutter/material.dart';
import 'package:index/screens/base_screen.dart';

class PrivacyPolicyScreen extends BaseScreen {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends BaseScreenState<PrivacyPolicyScreen> {
  @override
  String get screenName => 'Privacy Policy';

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سياسة الخصوصية'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.security,
                    size: 48,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'سياسة الخصوصية وشروط الاستخدام',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تطبيق Index',
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Introduction
            _buildSection(
              title: 'مقدمة',
              content: 'في تطبيق Index نحن نحترم خصوصيتك وخصوصية استخدامك للتطبيق. نحن لا نملك أي قاعدة بيانات لتخزين معلوماتك الشخصية مثل حسابك أو أي معلومات خاصة بالمستخدم.',
            ),
            
            const SizedBox(height: 20),
            
            // Privacy Policy Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.privacy_tip,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'سياسة الخصوصية',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSubSection(
                    title: '1. عدم جمع البيانات الشخصية:',
                    points: [
                      'تطبيق Index لا يقوم بجمع أو تخزين أي معلومات شخصية للمستخدم.',
                      'جميع استخداماتك للتطبيق تبقى على جهازك فقط.',
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildSubSection(
                    title: '2. المحتوى:',
                    points: [
                      'تطبيق Index يتيح لك مشاهدة الأفلام والمسلسلات مجانًا دون أي جهد مذكور أو إعلانات مزعجة.',
                      'نحن لا نمتلك هذه الأفلام، بل يتم جلبها من خلال مزود خدمات خارجي يقوم ببثها، ونحن نوفرها للعرض فقط.',
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Terms of Use Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.gavel,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'شروط الاستخدام',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSubSection(
                    title: '1. قبول الشروط:',
                    points: [
                      'باستخدامك تطبيق Index، فإنك توافق على الالتزام بهذه الشروط، ولديك الحق بعدم استخدام التطبيق إذا لم توافق عليها.',
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildSubSection(
                    title: '2. المسؤولية:',
                    points: [
                      'تقع كامل المسؤولية على المستخدم عند استخدام التطبيق.',
                      'نحن لا نتحمل أي مسؤولية عن أي أضرار أو مشاكل قد تحدث نتيجة استخدام التطبيق أو المحتوى المقدم.',
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildSubSection(
                    title: '3. الأمان واستغلال الثغرات:',
                    points: [
                      'يُمنع العبث بالتطبيق أو محاولة اكتشاف ثغرات لاستغلالها.',
                      'أي محاولة غير قانونية قد تؤدي إلى تعليق حسابك أو حظر الوصول للتطبيق نهائيًا.',
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildSubSection(
                    title: '4. حقوق الملكية:',
                    points: [
                      'جميع الحقوق محفوظة لشركة Voxin، المطور والراعي الرسمي للتطبيق.',
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'شكرًا لاستخدامك Index',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Voxin 2023 / تطبيق Index على Android',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildSubSection({
    required String title,
    required List<String> points,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...points.map((point) => Padding(
          padding: const EdgeInsets.only(bottom: 4, right: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 8, left: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  point,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}