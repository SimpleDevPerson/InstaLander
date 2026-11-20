# Room 2.2.5 creates WorkManager's generated database through Class.newInstance().
# Its consumer rule keeps the class but R8 full mode also needs the constructor.
-keep class androidx.work.impl.WorkDatabase_Impl {
    public <init>();
}
